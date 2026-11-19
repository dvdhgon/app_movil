from sqlalchemy import (
    Column,
    DateTime,
    Enum,
    ForeignKey,
    Integer,
    String,
    Text,
    func,
)
from database import Base


class Usuario(Base):
    __tablename__ = "usuario"

    id_usr = Column(Integer, primary_key=True, index=True)
    nom_usr = Column(String(100), nullable=False)
    mail = Column(String(150), unique=True, nullable=False)
    pass_hash = Column("pass", String(255), nullable=False)
    dir_usr = Column(String(200), nullable=True)
    tip_usu = Column(String(20), nullable=False, default="user")


class Blog(Base):
    __tablename__ = "blog"

    id_blog = Column(Integer, primary_key=True, index=True)
    titulo = Column(String(150), nullable=False)
    descripcion = Column("desc", Text, nullable=True)
    img = Column(String(500), nullable=True)
    tags = Column(String(255), nullable=True)


class Comentario(Base):
    __tablename__ = "comentarios"

    id_com = Column(Integer, primary_key=True, index=True)
    comentario = Column(Text, nullable=False)
    fecha = Column(
        DateTime,
        nullable=False,
        server_default=func.current_timestamp(),
    )
    estatus = Column(Integer, nullable=False, default=1)
    usr_id = Column(
        Integer,
        ForeignKey("usuario.id_usr", ondelete="CASCADE"),
        nullable=False,
    )
    blog_id = Column(
        Integer,
        ForeignKey("blog.id_blog", ondelete="CASCADE"),
        nullable=False,
    )


class WebPublicacion(Base):
    __tablename__ = "web_publicaciones"

    id_publicacion = Column(Integer, primary_key=True, index=True)
    titulo = Column(String(255), nullable=False)
    contenido = Column(Text, nullable=False)
    imagen = Column(String(255), nullable=True)
    etiquetas = Column(String(255), nullable=True)
    estado = Column(Enum("borrador", "publicada"), default="publicada")
    fecha_publicacion = Column(DateTime, server_default=func.current_timestamp())
    id_autor = Column(
        Integer,
        ForeignKey("usuario.id_usr", ondelete="CASCADE"),
        nullable=False,
    )


class WebComentario(Base):
    __tablename__ = "web_comentarios"

    id_comentario = Column(Integer, primary_key=True, index=True)
    comentario = Column(Text, nullable=False)
    fecha_comentario = Column(DateTime, server_default=func.current_timestamp())
    id_usuario = Column(
        Integer,
        ForeignKey("usuario.id_usr", ondelete="CASCADE"),
        nullable=False,
    )
    id_publicacion = Column(
        Integer,
        ForeignKey("web_publicaciones.id_publicacion", ondelete="CASCADE"),
        nullable=False,
    )