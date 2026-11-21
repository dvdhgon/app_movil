import base64
import os
import shutil
import uuid
from contextlib import asynccontextmanager
from pathlib import Path

import bcrypt
from database import Base, engine, obtener_sesion
from fastapi import Depends, FastAPI, File, Form, HTTPException, Request, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from models import Blog, Comentario, Usuario
from pwdlib import PasswordHash
from schemas import (
    BlogCrear,
    BlogRespuesta,
    ComentarioCrear,
    ComentarioRespuesta,
    LoginRequest,
    UsuarioActualizar,
    UsuarioCrear,
    UsuarioRespuesta,
)
from sqlalchemy import delete, inspect, select, text
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

argon2_hasher = PasswordHash.recommended()


def encriptar_password(plain_password: str) -> str:
    hashed = bcrypt.hashpw(plain_password.encode("utf-8"), bcrypt.gensalt())
    return hashed.decode("utf-8")


def verificar_password(plain_password: str, stored_password: str) -> bool:
    if not stored_password:
        return False

    # Manejo de hashes bcrypt ($2y$, $2b$, $2a$)
    if stored_password.startswith(("$2y$", "$2b$", "$2a$")):
        try:
            hash_normalizado = (
                "$2b$" + stored_password[4:]
                if stored_password.startswith("$2y$")
                else stored_password
            )
            return bcrypt.checkpw(
                plain_password.encode("utf-8"), hash_normalizado.encode("utf-8")
            )
        except Exception as e:
            print(f"Aviso verificación bcrypt: {e}")
            return False

    # Manejo de hashes Argon2
    if stored_password.startswith("$argon2"):
        try:
            return argon2_hasher.verify(plain_password, stored_password)
        except Exception:
            return False

    # Comparación de texto plano de respaldo (para usuarios heredados)
    return plain_password == stored_password


def rol_a_bd(tip_usu) -> int:
    """Convierte cualquier representación de rol al entero correspondiente para MySQL (1=Admin, 2=Usuario)."""
    if tip_usu is None:
        return 2
    val = str(tip_usu).strip().lower()
    if val in ("1", "admin", "administrador"):
        return 1
    return 2


UPLOAD_DIR = Path("uploads")
UPLOAD_DIR.mkdir(exist_ok=True)


def guardar_imagen_base64(datos_base64: str) -> str | None:
    """Decodifica un string en formato base64 y lo almacena en la carpeta uploads."""
    try:
        header = ""
        extension = ".jpg"
        contenido = datos_base64

        if "," in datos_base64:
            partes = datos_base64.split(",", 1)
            header = partes[0]
            contenido = partes[1]
            if "image/png" in header:
                extension = ".png"
            elif "image/webp" in header:
                extension = ".webp"
            elif "image/gif" in header:
                extension = ".gif"

        bytes_imagen = base64.b64decode(contenido)
        nombre_archivo = f"img_{uuid.uuid4().hex[:12]}{extension}"
        destino = UPLOAD_DIR / nombre_archivo
        with open(destino, "wb") as f:
            f.write(bytes_imagen)

        return f"/uploads/{nombre_archivo}"
    except Exception as e:
        print(f"Error al decodificar imagen base64: {e}")
        return None


@asynccontextmanager
async def lifespan(app: FastAPI):
    Base.metadata.create_all(bind=engine)
    try:
        inspector = inspect(engine)
        columnas = [col["name"] for col in inspector.get_columns("usuario")]
        if "foto_perfil" not in columnas:
            with engine.begin() as conn:
                conn.execute(
                    text("ALTER TABLE usuario ADD COLUMN foto_perfil VARCHAR(500) NULL")
                )
    except Exception as e:
        print(f"Aviso columna foto_perfil: {e}")
    yield


app = FastAPI(
    title="API REST - Duncan Mascotas",
    description="Backend oficial con FastAPI y MySQL para la aplicación móvil Duncan Mascotas.",
    version="2.0.0",
    lifespan=lifespan,
)

app.mount("/uploads", StaticFiles(directory=UPLOAD_DIR), name="uploads")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def inicio():
    return {
        "status": "online",
        "mensaje": "API Duncan Mascotas en funcionamiento",
        "doc": "/docs",
    }


# ==========================================
# AUTENTICACIÓN / LOGIN
# ==========================================
@app.post("/login", response_model=UsuarioRespuesta)
def iniciar_sesion(
    datos: LoginRequest,
    db: Session = Depends(obtener_sesion),
):
    correo = datos.mail.strip().lower()
    usuario = db.scalar(select(Usuario).where(Usuario.mail == correo))

    if usuario is None or not verificar_password(datos.password, usuario.pass_hash):
        raise HTTPException(
            status_code=401,
            detail="Correo o contraseña incorrectos",
        )

    return usuario


# ==========================================
# REGISTRO Y GESTIÓN DE USUARIOS
# ==========================================
@app.post("/usuarios", response_model=UsuarioRespuesta, status_code=201)
def crear_usuario(
    usuario_in: UsuarioCrear,
    db: Session = Depends(obtener_sesion),
):
    correo = usuario_in.mail.strip().lower()
    existente = db.scalar(select(Usuario).where(Usuario.mail == correo))
    if existente:
        raise HTTPException(status_code=400, detail="El correo ya está registrado")

    nuevo_usuario = Usuario(
        nom_usr=usuario_in.nom_usr.strip(),
        mail=correo,
        pass_hash=encriptar_password(usuario_in.password),
        dir_usr=usuario_in.dir_usr,
        tip_usu=rol_a_bd(usuario_in.tip_usu),
    )
    db.add(nuevo_usuario)
    try:
        db.commit()
        db.refresh(nuevo_usuario)
    except IntegrityError:
        db.rollback()
        raise HTTPException(status_code=409, detail="El correo ya está registrado")

    return nuevo_usuario


@app.get("/usuarios", response_model=list[UsuarioRespuesta])
def listar_usuarios(db: Session = Depends(obtener_sesion)):
    return db.scalars(select(Usuario).order_by(Usuario.id_usr)).all()


@app.get("/usuarios/{id_usuario}", response_model=UsuarioRespuesta)
def obtener_usuario(id_usuario: int, db: Session = Depends(obtener_sesion)):
    usuario = db.get(Usuario, id_usuario)
    if not usuario:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    return usuario


@app.post("/usuarios/{id_usuario}/foto", response_model=UsuarioRespuesta)
async def subir_foto_perfil(
    id_usuario: int,
    foto: UploadFile = File(...),
    db: Session = Depends(obtener_sesion),
):
    usuario = db.get(Usuario, id_usuario)
    if not usuario:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")

    if not foto.filename:
        raise HTTPException(status_code=400, detail="No se recibió ningún archivo")

    extension = Path(foto.filename).suffix.lower()
    if extension not in [".jpg", ".jpeg", ".png", ".webp"]:
        raise HTTPException(
            status_code=400,
            detail="Formato no permitido. Usa JPG, PNG o WEBP",
        )

    nombre_archivo = f"perfil_{id_usuario}_{uuid.uuid4().hex[:10]}{extension}"
    destino = UPLOAD_DIR / nombre_archivo
    with destino.open("wb") as buffer:
        shutil.copyfileobj(foto.file, buffer)

    usuario.foto_perfil = f"/uploads/{nombre_archivo}"
    db.commit()
    db.refresh(usuario)
    return usuario


@app.put("/usuarios/{id_usuario}", response_model=UsuarioRespuesta)
def actualizar_usuario(
    id_usuario: int,
    usuario_in: UsuarioActualizar,
    db: Session = Depends(obtener_sesion),
):
    usuario = db.get(Usuario, id_usuario)
    if not usuario and usuario_in.mail:
        usuario = db.scalar(
            select(Usuario).where(Usuario.mail == usuario_in.mail.strip().lower())
        )
    if not usuario:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")

    if usuario_in.mail is not None:
        correo_limpio = usuario_in.mail.strip().lower()
        duplicado = db.scalar(
            select(Usuario).where(
                Usuario.mail == correo_limpio,
                Usuario.id_usr != usuario.id_usr,
            )
        )
        if duplicado:
            raise HTTPException(status_code=409, detail="El correo ya está registrado")
        usuario.mail = correo_limpio

    if usuario_in.nom_usr is not None:
        usuario.nom_usr = usuario_in.nom_usr.strip()
    if usuario_in.dir_usr is not None:
        usuario.dir_usr = usuario_in.dir_usr
    if usuario_in.tip_usu is not None:
        usuario.tip_usu = rol_a_bd(usuario_in.tip_usu)
    if usuario_in.foto_perfil is not None:
        usuario.foto_perfil = usuario_in.foto_perfil
    if usuario_in.password is not None:
        usuario.pass_hash = encriptar_password(usuario_in.password)

    try:
        db.commit()
        db.refresh(usuario)
    except IntegrityError:
        db.rollback()
        raise HTTPException(status_code=409, detail="El correo ya está registrado")

    return usuario


@app.delete("/usuarios/{id_usuario}")
def eliminar_usuario(id_usuario: int, db: Session = Depends(obtener_sesion)):
    usuario = db.get(Usuario, id_usuario)
    if not usuario:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")

    db.execute(delete(Comentario).where(Comentario.usr_id == id_usuario))
    db.delete(usuario)
    db.commit()
    return {"mensaje": "Usuario eliminado correctamente"}


# ==========================================
# PUBLICACIONES / BLOG (COMPATIBLE CON JSON Y FORM)
# ==========================================
@app.get("/blog", response_model=list[BlogRespuesta])
@app.get("/blogs", response_model=list[BlogRespuesta])
def listar_blogs(db: Session = Depends(obtener_sesion)):
    return db.scalars(select(Blog).order_by(Blog.id_blog.desc())).all()


@app.get("/blog/{blog_id}", response_model=BlogRespuesta)
@app.get("/blogs/{blog_id}", response_model=BlogRespuesta)
def obtener_blog(blog_id: int, db: Session = Depends(obtener_sesion)):
    publicacion = db.get(Blog, blog_id)
    if publicacion is None:
        raise HTTPException(status_code=404, detail="Publicación no encontrada")
    return publicacion


@app.post("/blog", response_model=BlogRespuesta, status_code=201)
@app.post("/blogs", response_model=BlogRespuesta, status_code=201)
async def crear_blog(
    request: Request,
    db: Session = Depends(obtener_sesion),
):
    """
    Permite registrar blogs recibiendo tanto JSON (desde Flutter HTTP) como multipart/form-data.
    Procesa automáticamente imágenes en base64 y archivos binarios.
    """
    content_type = request.headers.get("content-type", "")

    titulo = ""
    descripcion = ""
    tags = None
    ruta_imagen = None

    if "application/json" in content_type:
        datos = await request.json()
        titulo = datos.get("titulo", "").strip()
        descripcion = (datos.get("descripcion") or datos.get("contenido") or "Sin contenido").strip()
        tags = datos.get("tags")
        if tags and str(tags).strip():
            tags = str(tags).strip()
        else:
            tags = None

        img_raw = datos.get("img") or datos.get("imagen")
        if img_raw:
            img_str = str(img_raw).strip()
            if img_str.startswith("data:image") or (len(img_str) > 100 and ";" not in img_str and "/" not in img_str[:15]):
                ruta_imagen = guardar_imagen_base64(img_str)
            else:
                ruta_imagen = img_str
    else:
        form = await request.form()
        titulo = str(form.get("titulo", "")).strip()
        descripcion = str(form.get("descripcion") or form.get("contenido") or "Sin contenido").strip()
        tags_raw = form.get("tags")
        tags = str(tags_raw).strip() if tags_raw else None

        archivo = form.get("imagen") or form.get("img")
        if archivo and hasattr(archivo, "filename") and archivo.filename:
            extension = Path(archivo.filename).suffix.lower()
            if extension in [".jpg", ".jpeg", ".png", ".webp"]:
                nombre_archivo = f"blog_{uuid.uuid4().hex[:12]}{extension}"
                destino = UPLOAD_DIR / nombre_archivo
                with destino.open("wb") as buffer:
                    shutil.copyfileobj(archivo.file, buffer)
                ruta_imagen = f"/uploads/{nombre_archivo}"

    if not titulo:
        raise HTTPException(status_code=422, detail="El título es obligatorio")

    nuevo_blog = Blog(
        titulo=titulo,
        descripcion=descripcion,
        img=ruta_imagen,
        tags=tags,
    )
    db.add(nuevo_blog)
    db.commit()
    db.refresh(nuevo_blog)
    return nuevo_blog


# ==========================================
# COMENTARIOS (CON NOMBRE DE AUTOR)
# ==========================================
@app.get("/comentarios", response_model=list[ComentarioRespuesta])
def listar_comentarios(
    blog_id: int | None = None,
    db: Session = Depends(obtener_sesion),
):
    query = (
        select(Comentario, Usuario.nom_usr)
        .outerjoin(Usuario, Comentario.usr_id == Usuario.id_usr)
        .order_by(Comentario.id_com.asc())
    )
    if blog_id is not None:
        query = query.where(Comentario.blog_id == blog_id)

    resultados = db.execute(query).all()
    lista = []
    for com, autor_nombre in resultados:
        lista.append(
            ComentarioRespuesta(
                id_com=com.id_com,
                comentario=com.comentario,
                fecha=com.fecha,
                estatus=com.estatus,
                usr_id=com.usr_id,
                blog_id=com.blog_id,
                autor=autor_nombre or "Usuario registrado",
            )
        )
    return lista


@app.post("/comentarios", response_model=ComentarioRespuesta, status_code=201)
def crear_comentario(
    datos: ComentarioCrear,
    db: Session = Depends(obtener_sesion),
):
    if not datos.comentario.strip():
        raise HTTPException(status_code=422, detail="El comentario no puede estar vacío")

    usuario = db.get(Usuario, datos.usr_id)
    if usuario is None:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")

    blog = db.get(Blog, datos.blog_id)
    if blog is None:
        raise HTTPException(status_code=404, detail="Publicación no encontrada")

    nuevo = Comentario(
        comentario=datos.comentario.strip(),
        usr_id=datos.usr_id,
        blog_id=datos.blog_id,
        estatus=1,
    )
    db.add(nuevo)
    db.commit()
    db.refresh(nuevo)

    return ComentarioRespuesta(
        id_com=nuevo.id_com,
        comentario=nuevo.comentario,
        fecha=nuevo.fecha,
        estatus=nuevo.estatus,
        usr_id=nuevo.usr_id,
        blog_id=nuevo.blog_id,
        autor=usuario.nom_usr,
    )
