from datetime import datetime
from pydantic import BaseModel, ConfigDict, Field, field_validator


# ==========================================
# USUARIOS Y LOGIN (COMPARTIDO WEB / MÓVIL)
# ==========================================
class UsuarioCrear(BaseModel):
    nom_usr: str = Field(min_length=2, max_length=100)
    mail: str = Field(min_length=5, max_length=150)
    password: str = Field(min_length=6, max_length=128)
    dir_usr: str | None = None
    tip_usu: int | str = 2


class UsuarioRespuesta(BaseModel):
    id_usr: int
    nom_usr: str
    mail: str
    dir_usr: str | None = None
    tip_usu: int

    model_config = ConfigDict(from_attributes=True)

    @field_validator("tip_usu", mode="before")
    @classmethod
    def convertir_rol_a_numero(cls, value):
        if isinstance(value, str):
            val = value.strip().lower()
            if val in ("admin", "administrador", "1"):
                return 1
            return 2
        if isinstance(value, int):
            return 1 if value == 1 else 2
        return 2


class UsuarioActualizar(BaseModel):
    nom_usr: str | None = Field(default=None, min_length=2, max_length=100)
    mail: str | None = Field(default=None, min_length=5, max_length=150)
    password: str | None = Field(default=None, min_length=6, max_length=128)
    dir_usr: str | None = None
    tip_usu: int | str | None = None

    @field_validator("nom_usr", "mail", "password", "dir_usr", mode="before")
    @classmethod
    def vacio_a_none(cls, value):
        if isinstance(value, str) and not value.strip():
            return None
        return value


class LoginRequest(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    mail: str = Field(min_length=5, max_length=150)
    password: str = Field(min_length=1, max_length=128)


# ==========================================
# BLOG (APP MÓVIL)
# ==========================================
class BlogCrear(BaseModel):
    titulo: str = Field(min_length=2, max_length=150)
    descripcion: str = Field(min_length=1)
    img: str | None = Field(default=None, max_length=500)
    tags: str | None = Field(default=None, max_length=255)


class BlogRespuesta(BaseModel):
    id_blog: int
    titulo: str
    descripcion: str | None = None
    img: str | None = None
    tags: str | None = None

    model_config = ConfigDict(from_attributes=True)


# ==========================================
# COMENTARIOS (APP MÓVIL)
# ==========================================
class ComentarioCrear(BaseModel):
    comentario: str = Field(min_length=1)
    usr_id: int
    blog_id: int
    estatus: int = 1


class ComentarioRespuesta(BaseModel):
    id_com: int
    comentario: str
    fecha: datetime
    estatus: int
    usr_id: int
    blog_id: int

    model_config = ConfigDict(from_attributes=True)