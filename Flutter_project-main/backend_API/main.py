import shutil
import uuid
from contextlib import asynccontextmanager
from pathlib import Path

import bcrypt
from database import Base, engine, obtener_sesion
from fastapi import Depends, FastAPI, File, Form, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from models import Blog, Comentario, Usuario
from pwdlib import PasswordHash
from schemas import (
    ComentarioCrear,
    ComentarioRespuesta,
    LoginRequest,
    UsuarioActualizar,
    UsuarioCrear,
    UsuarioRespuesta,
)
from sqlalchemy import delete, select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

argon2_hasher = PasswordHash.recommended()


def encriptar_password(plain_password: str) -> str:
    hashed = bcrypt.hashpw(plain_password.encode("utf-8"), bcrypt.gensalt())
    return hashed.decode("utf-8")


def verificar_password(plain_password: str, stored_password: str) -> bool:
    if not stored_password:
        return False

    if stored_password.startswith(("$2y$", "$2b$", "$2a$")):
        try:
            hash_normalizado = ("$2b$" + stored_password[4:]).encode("utf-8")
            return bcrypt.checkpw(plain_password.encode("utf-8"), hash_normalizado)
        except Exception:
            return False

    if stored_password.startswith("$argon2"):
        try:
            return argon2_hasher.verify(plain_password, stored_password)
        except Exception:
            return False

    return plain_password == stored_password


def rol_a_bd(tip_usu) -> str:
    if tip_usu is None:
        return "user"
    val = str(tip_usu).strip().lower()
    if val in ("1", "admin", "administrador"):
        return "admin"
    return "user"


@asynccontextmanager
async def lifespan(app: FastAPI):
    Base.metadata.create_all(bind=engine)
    yield


app = FastAPI(
    title="API de aplicación móvil - Sistema Duncan",
    lifespan=lifespan,
)

UPLOAD_DIR = Path("uploads")
UPLOAD_DIR.mkdir(exist_ok=True)
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
    return {"mensaje": "API funcionando correctamente con sistema_duncan"}


# ==========================================
# AUTENTICACIÓN / LOGIN COMPARTIDO
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


@app.put("/usuarios/{id_usuario}", response_model=UsuarioRespuesta)
def actualizar_usuario(
    id_usuario: int,
    usuario_in: UsuarioActualizar,
    db: Session = Depends(obtener_sesion),
):
    usuario = db.get(Usuario, id_usuario)
    if not usuario:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")

    if usuario_in.mail is not None:
        correo_limpio = usuario_in.mail.strip().lower()
        duplicado = db.scalar(
            select(Usuario).where(
                Usuario.mail == correo_limpio,
                Usuario.id_usr != id_usuario,
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
# PUBLICACIONES / BLOG (APP MÓVIL)
# ==========================================
@app.get("/blog")
@app.get("/blogs")
def listar_blogs(db: Session = Depends(obtener_sesion)):
    return db.scalars(select(Blog).order_by(Blog.id_blog.desc())).all()


@app.get("/blog/{blog_id}")
@app.get("/blogs/{blog_id}")
def obtener_blog(blog_id: int, db: Session = Depends(obtener_sesion)):
    publicacion = db.get(Blog, blog_id)
    if publicacion is None:
        raise HTTPException(status_code=404, detail="Publicación no encontrada")
    return publicacion


@app.post("/blog", status_code=201)
@app.post("/blogs", status_code=201)
async def crear_blog(
    titulo: str = Form(...),
    contenido: str = Form(None),
    descripcion: str = Form(None),
    tags: str = Form(None),
    imagen: UploadFile = File(None),
    img: UploadFile = File(None),
    db: Session = Depends(obtener_sesion),
):
    texto_final = (descripcion or contenido or "Sin contenido").strip()
    archivo_imagen = imagen or img

    ruta_imagen = None
    if archivo_imagen and archivo_imagen.filename:
        extension = Path(archivo_imagen.filename).suffix.lower()
        if extension not in [".jpg", ".jpeg", ".png", ".webp"]:
            raise HTTPException(status_code=400, detail="Formato de imagen no permitido")
        nombre_archivo = f"{uuid.uuid4().hex}{extension}"
        destino = UPLOAD_DIR / nombre_archivo
        with destino.open("wb") as buffer:
            shutil.copyfileobj(archivo_imagen.file, buffer)
        ruta_imagen = f"/uploads/{nombre_archivo}"

    nuevo_blog = Blog(
        titulo=titulo.strip(),
        descripcion=texto_final,
        img=ruta_imagen,
        tags=tags.strip() if tags and tags.strip() else None,
    )
    db.add(nuevo_blog)
    db.commit()
    db.refresh(nuevo_blog)
    return nuevo_blog


# ==========================================
# COMENTARIOS (APP MÓVIL)
# ==========================================
@app.get("/comentarios", response_model=list[ComentarioRespuesta])
def listar_comentarios(db: Session = Depends(obtener_sesion)):
    return db.scalars(select(Comentario).order_by(Comentario.id_com)).all()


@app.post("/comentarios", response_model=ComentarioRespuesta, status_code=201)
def crear_comentario(
    datos: ComentarioCrear,
    db: Session = Depends(obtener_sesion),
):
    if not datos.comentario.strip():
        raise HTTPException(status_code=422, detail="El comentario no puede estar vacío")
    if db.get(Usuario, datos.usr_id) is None:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    if db.get(Blog, datos.blog_id) is None:
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
    return nuevo