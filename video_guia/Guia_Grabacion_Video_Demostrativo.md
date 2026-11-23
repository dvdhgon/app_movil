# Guia y Guion Tecnico para Grabacion del Video Demostrativo

Universidad Tecnologica de Queretaro (UTEQ)  
Materia: Aplicaciones Moviles | Evaluacion Unidad 3  
Alumnos: Aaron Alexander Paniagua Chavez, David Hernandez Gonzalez  
Docente: Adriana Y Contreras Alvarez  

---

## 1. Informacion Previa y Cuentas de Acceso Inyectadas

Para la grabacion del video se tienen preconfigurados en la base de datos MySQL los siguientes usuarios con contraseñas encriptadas mediante BCrypt:

1. Usuario Administrador (Rol 1):
   * Correo: `admin@duncan.com`
   * Contraseña: `Admin123*`
   * Rol: Administrador General (Tiene acceso a Gestion de usuarios, Creacion de blogs, Perfil y Mapa).

2. Usuario Autor / Estudiante Aaron (Rol 2):
   * Correo: `aaron@duncan.com`
   * Contraseña: `Aaron123*`
   * Rol: Usuario registrado / Autor (Tiene acceso a Feed de blog, Detalle, Crear comentarios, Publicar blog y Perfil).

3. Usuario Autor / Estudiante David (Rol 2):
   * Correo: `david@duncan.com`
   * Contraseña: `David123*`
   * Rol: Usuario registrado / Autor.

4. Usuario Docente de Prueba (Rol 1):
   * Correo: `adriana@uteq.edu.mx`
   * Contraseña: `Uteq2026*`
   * Rol: Administrador Docente.

---

## 2. Preparacion del Entorno antes de Iniciar la Grabacion

Antes de encender el software de grabacion (OBS Studio, Xbox Game Bar `Win + G` o grabador de pantalla):

1. Base de datos iniciada: Verifique que MySQL este corriendo en el puerto 3306.
2. Terminal 1 (Backend FastAPI):
   * En la carpeta `Flutter_project-main/backend_API`:
     `.\venv\Scripts\Activate.ps1`
     `uvicorn main:app --reload --host 127.0.0.1 --port 8000`
3. Terminal 2 (Frontend Flutter):
   * En la carpeta `Flutter_project-main/flutter_application_3`:
     `flutter run -d chrome`
4. Ventanas abiertas y listas en pantalla:
   * Ventana 1: Google Chrome con la aplicacion Flutter en `http://localhost:XXXXX`.
   * Ventana 2: MySQL Workbench, consola de MySQL o phpMyAdmin mostrando las tablas `usuario`, `blog`, `comentarios`.
   * Ventana 3: Google Chrome con la documentacion interactiva de Swagger UI en `http://127.0.0.1:8000/docs`.

---

## 3. Guion Paso a Paso de Grabacion (Checklist de la Rubrica)

Duracion recomendada: Entre 5 y 8 minutos.

### FASE 1: Presentacion y Portada (Tiempo aprox: 0:00 - 0:45)
* Accion en pantalla: Muestre la pantalla de inicio de sesion de la aplicacion y su editor o portada del reporte.
* Que decir:
  "Buenos dias/tardes profesora Adriana Contreras. Mi nombre es Aaron Alexander Paniagua Chavez, junto con mi compañero David Hernandez Gonzalez, presentamos la evidencia practica de la Evaluacion de la Unidad 3 para la materia de Aplicaciones Moviles de la carrera de TI en la UTEQ. Mostraremos el funcionamiento completo de nuestra plataforma Duncan Mascotas, integrada por una aplicacion en Flutter, backend REST en FastAPI y base de datos relacional MySQL."

### FASE 2: Validacion de Credenciales y Manejo Seguro de Sesion (Tiempo aprox: 0:45 - 2:00)
* Accion 1: Intento de inicio de sesion con credenciales invalidas.
  * Escriba: `correo_falso@ejemplo.com` y contraseña `erronea`.
  * Presione "Iniciar sesion".
  * Muestre que la aplicacion informa el error claramente mediante SnackBar ("Correo o contraseña incorrectos").
* Accion 2: Inicio de sesion exitoso como Usuario / Autor.
  * Escriba: `aaron@duncan.com` y contraseña `Aaron123*`.
  * Presione "Iniciar sesion".
  * La aplicacion navega inmediatamente al Feed de Blogs y muestra el saludo personalizado: "Hola, Aaron Alexander Paniagua Chavez".
* Que decir:
  "El backend recibe las credenciales y valida la contraseña contra el hash criptografico BCrypt almacenado en MySQL. Si las credenciales son incorrectas se deniega el acceso con codigo HTTP 401; de ser validas, se almacena la sesion localmente mediante SharedPreferences."

### FASE 3: Feed de Publicaciones y Detalle con Comentarios (Tiempo aprox: 2:00 - 3:30)
* Accion 1: Desplazamiento por el Feed de Publicaciones.
  * Muestre las tarjetas de las publicaciones con titulo, etiquetas e imagenes cargadas.
* Accion 2: Apertura de una publicacion.
  * De clic en la entrada "Guia esencial para el cuidado de cachorros".
  * Muestre la imagen en cabecera, etiquetas doradas y el cuerpo del articulo.
* Accion 3: Lectura y Creacion de Comentarios en tiempo real.
  * Muestre la seccion inferior "Comentarios de la Comunidad", con los comentarios previos y el nombre del autor de cada uno.
  * En la barra inferior, escriba un nuevo comentario: "Excelente guia, la pondre en practica con mi cachorro este fin de semana."
  * Presione el boton de enviar (icono de avioncito / send).
  * Muestre el mensaje de exito ("Comentario publicado correctamente") y como el nuevo comentario aparece instantaneamente en la lista vinculado a Aaron.
* Que decir:
  "Aqui evidenciamos el requisito de creacion y lectura de comentarios en las publicaciones. El comentario es enviado via HTTP POST en formato JSON a FastAPI, el cual valida la integridad de llaves foraneas en MySQL y devuelve el nuevo registro."

### FASE 4: Registro de un Nuevo Blog con Imagen (Cámara / Galeria) (Tiempo aprox: 3:30 - 4:45)
* Accion 1: Desde la pantalla del blog, presione el boton flotante "Nuevo Blog".
* Accion 2: Complete los campos:
  * Titulo: "Paseos nocturnos seguros para mascotas"
  * Descripcion: "Recomendaciones sobre el uso de collares reflejantes y rutas iluminadas durante la noche en Queretaro."
  * Tags: "Paseos, Seguridad, Queretaro"
* Accion 3: Presione "Seleccionar imagen" y elija una fotografia de su equipo. Muestre la vista previa de la imagen.
* Accion 4: Presione "Publicar Entrada".
* Accion 5: Muestre como el Feed se actualiza y la nueva publicacion aparece en el primer lugar con su imagen y descripcion.
* Que decir:
  "La aplicacion permite subir imagenes desde el dispositivo. La imagen es transferida al servidor FastAPI, el cual la almacena en el directorio uploads y persiste la ruta relativa en la base de datos."

### FASE 5: Rol Administrador y Gestion de Usuarios (CRUD) (Tiempo aprox: 4:45 - 6:00)
* Accion 1: Cierre sesion desde el boton superior derecho.
* Accion 2: Inicie sesion con la cuenta de Administrador:
  * Correo: `admin@duncan.com`
  * Contraseña: `Admin123*`
* Accion 3: Al iniciar sesion como Administrador (Rol 1), la aplicacion redirige al panel de "Gestion de Usuarios" y despliega el menu lateral (Admin Drawer).
* Accion 4: Demuestre la lectura de todos los usuarios registrados en MySQL.
* Accion 5: De clic en editar en un usuario para modificar su nombre o direccion y guarde los cambios.
* Accion 6: Abra el Admin Drawer y muestre la opcion "Mapa de lugares" (Geolocalizacion GPS de rutas y parques de Queretaro: Centro Historico, Los Arcos, Alameda Hidalgo).
* Que decir:
  "Al autenticar con rol 1, se activa el control de acceso administrativo. El administrador cuenta con facultades para gestionar usuarios, revisar la comunidad e inspeccionar los puntos de interes canino integrados con el mapa."

### FASE 6: Evidencia de Acceso a Datos en MySQL y Swagger (Tiempo aprox: 6:00 - 7:00)
* Accion 1: Cambie a la ventana de MySQL Workbench o su consola.
* Accion 2: Ejecute:
  `SELECT * FROM usuario;` (muestre los hashes BCrypt y los usuarios).
  `SELECT * FROM comentarios ORDER BY id_com DESC LIMIT 5;` (muestre el comentario que acaba de redactar hace un momento en la app).
  `SELECT * FROM blog ORDER BY id_blog DESC LIMIT 3;` (muestre la publicacion que acaba de crear con su imagen).
* Accion 3: Muestre brevemente la documentacion de FastAPI en `http://127.0.0.1:8000/docs` mostrando los esquemas Pydantic y los metodos GET, POST, PUT y DELETE.
* Que decir:
  "Como se aprecia en la base de datos MySQL, los datos se sincronizan de manera inmediata e integra. Las contraseñas se encuentran encriptadas de forma irreversible con BCrypt, garantizando que jamas se almacenen en texto plano."

### FASE 7: Conclusion y Cierre (Tiempo aprox: 7:00 - 7:30)
* Que decir:
  "Con esto concluimos la demostracion practica cumpliendo al 100% con los criterios de la rubrica: autenticacion segura, encriptacion de contraseñas, control de acceso por roles, lectura y publicacion de posts, creacion y lectura de comentarios, e integracion funcional entre Flutter, FastAPI y MySQL. Muchas gracias por su atencion."
