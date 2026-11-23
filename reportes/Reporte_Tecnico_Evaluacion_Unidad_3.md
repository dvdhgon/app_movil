# UNIVERSIDAD TECNOLÓGICA DE QUERÉTARO
## DIVISIÓN DE TECNOLOGÍAS DE LA INFORMACIÓN Y COMUNICACIÓN
### LICENCIATURA EN INGENIERÍA EN TECNOLOGÍAS DE LA INFORMACIÓN E INNOVACIÓN DIGITAL

---

# REPORTE TÉCNICO DE PROYECTO INTEGRAL
## CASO PRÁCTICO: DUNCAN MASCOTAS - SISTEMA DE BLOG MULTIPLATAFORMA
### EVALUACIÓN UNIDAD 3

**Materia:** Aplicaciones Móviles  
**Grupo:** LITIID014  
**Docente:** Profesora Adriana Y Contreras Alvarez  
**Fecha de Entrega:** Noviembre de 2026  

**Integrantes del Equipo de Desarrollo:**
* Aaron Alexander Paniagua Chávez
* David Hernández González

**Repositorio Oficial en GitHub:** https://github.com/dvdhgon/app_movil  

> **Leyenda de Evaluación:**  
> **"Actividad para alcanzar 10 Puntos"**  
> *(Desglose de ponderación: 30 Puntos / 30% Reporte Técnico Digital + 70 Puntos / 70% Repositorio Público y Despliegue Funcional en GitHub)*

---

## 1. Introducción y Contexto del Caso Práctico

El presente documento técnico documenta el diseño, la arquitectura de software, la implementación técnica y los mecanismos de seguridad del proyecto **Duncan Mascotas**. La solución responde al caso práctico de desarrollo de un sistema multiplataforma enfocado en la divulgación de contenidos sobre bienestar, cuidado, nutrición y paseos de perros, propiciando una comunidad interactiva entre cuidadores de mascotas y profesionales del sector.

El sistema fue concebido bajo una arquitectura cliente-servidor completamente desacoplada compuesta por tres componentes principales:
1. **Frontend Móvil y Web:** Diseñado con el framework **Flutter** y lenguaje **Dart**, permitiendo una experiencia de usuario consistente, fluida y reactiva tanto en dispositivos móviles (Android/iOS) como en navegadores web de escritorio (Google Chrome).
2. **Backend de Servicios:** Construido mediante el framework asíncrono **FastAPI** en lenguaje **Python**, proveyendo una interfaz de programación de aplicaciones (API RESTful) de alto rendimiento, modular y autodocumentada bajo el estándar OpenAPI / Swagger.
3. **Capa de Persistencia:** Implementada sobre el motor de base de datos relacional **MySQL 8.0** con almacenamiento InnoDB, aplicando codificación de caracteres `utf8mb4` para soporte internacional de texto y emojis, y garantizando integridad referencial mediante claves foráneas y cascadas.

---

## 2. Diagramas de Clases y Modelo de Datos Relacional

### 2.1 Modelo Entidad-Relación y Estructura Relacional (MySQL)

El modelo de datos relacional de la base de datos `bd_aplicacion_movil` se compone de tres entidades fundamentales normalizadas en tercera forma normal (3FN):

1. **Tabla `usuario`:**
   Almacena los datos de identidad y acreditación de los agentes del sistema.
   * `id_usr` (INT, Clave Primaria, Auto-incrementable): Identificador único del usuario.
   * `nom_usr` (VARCHAR(100), NOT NULL): Nombre completo o alias del usuario.
   * `mail` (VARCHAR(150), NOT NULL, UNIQUE): Dirección de correo electrónico utilizada como credencial de inicio de sesión.
   * `pass` (VARCHAR(255), NOT NULL): Contraseña del usuario almacenada exclusivamente como hash criptográfico seguro generado mediante BCrypt / Argon2. Jamás se almacena en texto claro.
   * `dir_usr` (VARCHAR(200), NULL): Dirección o ubicación residencial del usuario.
   * `tip_usu` (INT, NOT NULL, DEFAULT 2): Nivel de rol y privilegios dentro de la plataforma (1 = Administrador con privilegios de gestión de usuarios; 2 = Usuario registrado / Autor de publicaciones).
   * `foto_perfil` (VARCHAR(500), NULL): Ruta relativa en el servidor (`/uploads/...`) hacia el archivo de imagen de perfil subido por el usuario.

2. **Tabla `blog`:**
   Registra los artículos y entradas del blog publicados en la plataforma.
   * `id_blog` (INT, Clave Primaria, Auto-incrementable): Identificador numérico de la publicación.
   * `titulo` (VARCHAR(150), NOT NULL): Título principal del artículo.
   * `desc` (TEXT, NULL): Cuerpo y contenido descriptivo del artículo.
   * `img` (VARCHAR(500), NULL): Ruta local del servidor o URL absoluta de la imagen ilustrativa de cabecera.
   * `tags` (VARCHAR(255), NULL): Etiquetas temáticas separadas por comas (por ejemplo: "Cachorros, Bienestar, Nutrición").

3. **Tabla `comentarios`:**
   Contiene las participaciones de los usuarios en cada publicación del blog.
   * `id_com` (INT, Clave Primaria, Auto-incrementable): Identificador único del comentario.
   * `comentario` (TEXT, NOT NULL): Mensaje redactado por el usuario.
   * `fecha` (DATETIME, NOT NULL, DEFAULT CURRENT_TIMESTAMP): Marca temporal exacta en la que se registró el comentario.
   * `estatus` (INT, NOT NULL, DEFAULT 1): Bandera de visibilidad (1 = Visible/Aprobado; 0 = Oculto/Moderado).
   * `usr_id` (INT, Clave Foránea referenciando a `usuario.id_usr`): Identificador del autor del comentario. Restricción `ON DELETE CASCADE`.
   * `blog_id` (INT, Clave Foránea referenciando a `blog.id_blog`): Identificador de la publicación comentada. Restricción `ON DELETE CASCADE`.

#### Relaciones de Cardinalidad:
* Un `usuario` puede redactar de 0 a muchos (`0..N`) `comentarios`.
* Un `blog` puede albergar de 0 a muchos (`0..N`) `comentarios`.
* La eliminación de un usuario o de una publicación desencadena la eliminación automática de los comentarios vinculados, preservando la consistencia e impidiendo registros huérfanos.

### 2.2 Diagrama de Clases del Sistema (Backend y Frontend)

La arquitectura de clases se encuentra dividida entre el dominio del servidor (FastAPI + SQLAlchemy) y el cliente móvil (Flutter + Dart):

* **Clases del Backend (Capa de Dominio y Acceso a Datos):**
  * `Usuario` (SQLAlchemy ORM): Mapea la tabla `usuario`, gestiona atributos de seguridad y establece la relación inversa `comentarios` hacia la clase `Comentario`.
  * `Blog` (SQLAlchemy ORM): Mapea la tabla `blog` y define la colección de comentarios asociados.
  * `Comentario` (SQLAlchemy ORM): Mapea la tabla `comentarios`, con referencias bidireccionales hacia `Usuario` y `Blog`.
  * Clases DTO / Pydantic: `UsuarioCrear`, `UsuarioRespuesta`, `UsuarioActualizar`, `LoginRequest`, `BlogCrear`, `BlogRespuesta`, `ComentarioCrear`, `ComentarioRespuesta`. Se encargan de validar tipos, aplicar restricciones de longitud y serializar respuestas JSON.

* **Clases del Frontend (Modelos de Entidad y Servicios HTTP en Flutter):**
  * `UserModel`: Modela al usuario en la aplicación móvil, implementando métodos de serialización `fromJson()`, `toJsonCrear()` y `toJsonActualizar()`.
  * `PostModel`: Representa las publicaciones en las listas y vistas de detalle.
  * `ComentarioModel`: Almacena el contenido, la fecha y el nombre legible del autor para su renderizado en la interfaz.
  * `AuthService`: Gestiona la petición de autenticación (`/login`) y validaciones sintácticas previas de formularios.
  * `UserService`: Proporciona métodos CRUD para la administración de usuarios y la subida de fotografía de perfil multipart.
  * `PostService`: Consume los endpoints `/blog` para la consulta y registro de entradas.
  * `ComentarioService`: Realiza las peticiones `GET /comentarios?blog_id={id}` y `POST /comentarios`.

*(Los diagramas en formato vectorial editable se encuentran disponibles en los archivos `diagrama_clases.drawio` y `diagrama_entidad_relacion.drawio` dentro del repositorio).*

---

## 3. Justificación del Uso de Sensores y Recursos Multimedia

De acuerdo con los lineamientos de la rúbrica técnica de aplicaciones móviles, el proyecto justifica y hace uso efectivo de sensores del dispositivo móvil y gestión de recursos multimedia:

### 3.1 Sensor de Cámara y Galería de Imágenes (Hardware Image Sensor)
* **Librería implementada:** `image_picker` (versión compatible con Flutter 3.x).
* **Justificación técnica y caso de uso:**
  En una plataforma de mascotas y blog comunitario, la evidencia gráfica es vital para transmitir información sobre síntomas, técnicas de adiestramiento, productos caninos o identificación de paseadores. El sistema implementa la captura mediante la cámara física del dispositivo o la selección de fotografías desde la galería del almacenamiento local en dos módulos esenciales:
  1. **Fotografía de Perfil de Usuario:** En la pantalla `ProfilePage`, el usuario puede accionar el icono de cámara para tomar una fotografía instantánea o elegir un archivo local. La imagen es procesada, redimensionada a una resolución óptima para no saturar el ancho de banda y enviada mediante una solicitud HTTP multipart al backend, donde se almacena en el directorio `uploads/` y se vincula al perfil en MySQL.
  2. **Fotografía de Publicación de Blog:** En la pantalla `AddBlogPage`, el autor de un artículo puede ilustrar su publicación tomando una foto con la cámara del dispositivo móvil. Esta imagen es codificada en base de datos y persistida en el servidor para enriquecer el catálogo visual del feed.

### 3.2 Sensor de Geolocalización GPS y Mapeo Satelital
* **Librería implementada:** `google_maps_flutter`.
* **Justificación técnica y caso de uso:**
  El cuidado y bienestar de los perros requiere paseos frecuentes en espacios seguros, abiertos y amigables con las mascotas (*pet-friendly*). El sistema incorpora la vista interactiva `MapaPage`, la cual aprovecha los servicios de posicionamiento y cartografía satelital para ubicar geográficamente los puntos emblemáticos de recreación canina en la ciudad de Santiago de Querétaro:
  * Plaza de Armas (Centro Histórico): Coordenadas `(20.588793, -100.389888)`.
  * Acueducto de Querétaro (Los Arcos): Coordenadas `(20.593649, -100.370395)`.
  * Alameda Hidalgo: Coordenadas `(20.587836, -100.387063)`.
  * Cerro de las Campanas: Coordenadas `(20.592582, -100.409395)`.
  Los marcadores en pantalla muestran ventanas de información contextual con el nombre del parque y recomendaciones para los paseadores de Duncan Mascotas.

---

## 4. Descripción de Recursos Multimedia y Librerías Utilizadas

A continuación se detalla el ecosistema de dependencias y librerías de software implementadas en el proyecto:

### 4.1 Ecosistema del Backend (Python / FastAPI)
* **FastAPI:** Framework web moderno de alto rendimiento basado en tipado estándar de Python. Gestiona el enrutamiento RESTful, la inyección de dependencias (`Depends`) y la generación automática de contratos OpenAPI / Swagger.
* **Uvicorn:** Servidor ASGI para Python que ejecuta la aplicación de forma concurrente sobre el protocolo HTTP/1.1 y WebSockets.
* **SQLAlchemy 2.0:** Object-Relational Mapping (ORM) de grado empresarial que abstrae las operaciones SQL a objetos Python, gestionando el ciclo de vida de sesiones, transacciones atómicas y pool de conexiones.
* **PyMySQL:** Conector de bajo nivel que permite la comunicación pura en Python con el servidor MySQL mediante sockets TCP/IP.
* **BCrypt:** Algoritmo criptográfico estándar de derivación de claves que incorpora sal (*salt*) aleatoria e iteraciones de cómputo adaptativas para hacer invulnerables las contraseñas ante ataques de fuerza bruta y tablas arcoíris.
* **Argon2 (pwdlib):** Algoritmo criptográfico de última generación ganador del Password Hashing Competition (PHC), soportado como mecanismo alternativo de verificación segura.
* **Pydantic 2.x:** Motor de validación y parseo de datos basado en anotaciones de tipo de Python, asegurando que cualquier solicitud entrante cumpla estrictamente con los esquemas esperados antes de ser procesada.
* **python-multipart:** Permite la recepción y procesamiento eficiente de archivos binarios subidos mediante formularios HTTP multipart (`UploadFile`).
* **Starlette StaticFiles:** Módulo para servir de manera eficiente y segura archivos multimedia estáticos desde el directorio `uploads/`.

### 4.2 Ecosistema del Frontend (Flutter / Dart)
* **http:** Paquete oficial de Dart para efectuar peticiones de red asíncronas (GET, POST, PUT, DELETE) con codificación de cabeceras JSON y soporte de tiempo de espera (*timeout*).
* **shared_preferences:** Plugin multiplataforma que implementa persistencia local en el dispositivo (utilizando NSUserDefaults en iOS, SharedPreferences en Android y LocalStorage en Web) para retener la sesión del usuario de manera persistente tras el cierre de la aplicación.
* **image_picker:** Plugin nativo para captura de fotos con la cámara física o selección desde la fototeca/galería del sistema operativo.
* **google_maps_flutter:** Componente de mapa vectorial interactivo de Google Maps.
* **Material Design 3:** Sistema de diseño visual moderno aplicado con la paleta de colores oficial de Duncan Mascotas: Vino tinto (`#722F37`), Vino oscuro (`#5A252B`), Dorado elegante (`#D4AF37`) y Blanco marfil (`#FAF7F5`).

---

## 5. Mecanismos de Seguridad Implementados

El sistema implementa una sólida postura de seguridad en profundidad cubriendo todos los aspectos requeridos por la rúbrica de evaluación:

### 5.1 Encriptación Irreversible de Contraseñas (BCrypt y Argon2)
Las contraseñas de los usuarios jamás son almacenadas ni transmitidas en texto claro hacia la base de datos. En el momento en que un usuario se registra o actualiza su contraseña:
1. La función `encriptar_password(plain_password)` del backend ejecuta `bcrypt.hashpw()` generando un *salt* criptográfico aleatorio de 12 rondas.
2. La cadena resultante (formato `$2b$12$...`) tiene una longitud fija de 60 caracteres y es la única que se almacena en la columna `pass` de la tabla `usuario`.
3. Al momento de iniciar sesión (`POST /login`), la función `verificar_password()` extrae el hash almacenado y utiliza `bcrypt.checkpw()` para contrastar la contraseña provista. Este proceso es resistente a ataques de tiempo (*timing attacks*) y garantiza que aún en caso de una filtración de la base de datos, las contraseñas reales de los usuarios no puedan ser recuperadas.

### 5.2 Control de Acceso Basado en Roles (RBAC)
El sistema implementa una clara segregación de funciones mediante el atributo numérico `tip_usu`:
* **Rol 1 (Administrador):**
  Al iniciar sesión con rol 1, la aplicación Flutter redirige al panel de administración `UsersPage` y habilita el cajón lateral de navegación `AdminDrawer`. El administrador posee facultades exclusivas para listar la totalidad de los usuarios registrados en el sistema, modificar sus datos, consultar el mapa de rutas y supervisar publicaciones.
* **Rol 2 (Usuario Regular / Autor):**
  Al autenticarse con rol 2, el usuario es dirigido directamente al feed principal del blog (`BlogPage`). No tiene acceso al panel de administración de usuarios de otros agentes, pero cuenta con permisos para publicar nuevas entradas con fotografía, leer artículos completos y participar activamente mediante comentarios.

### 5.3 Mitigación de Ataques de Inyección SQL
Toda interacción con la base de datos MySQL se realiza a través de las abstracciones de SQLAlchemy 2.0 y consultas parametrizadas. Ninguna variable enviada por el usuario es concatenada directamente en sentencias SQL. Los parámetros son transferidos de forma aislada al motor MySQL, garantizando la imposibilidad de inyectar código SQL malicioso.

### 5.4 Control de Origen Cruzado (CORS) y Sanitización de Entradas
El servidor FastAPI incluye el middleware `CORSMiddleware`, configurado para controlar los métodos y orígenes permitidos. Adicionalmente, todos los cuerpos de solicitud JSON son validados por esquemas Pydantic que imponen longitudes mínimas y máximas, validación de formatos de correo electrónico y sanitización de espacios en blanco mediante validadores de campo.

### 5.5 Manejo Seguro de Sesión Local
En el cliente Flutter, al autenticarse exitosamente, el payload validado del usuario se almacena localmente en `SharedPreferences` bajo la llave `usuario_sesion`. Al navegar entre pantallas o cerrar y reabrir la aplicación, el estado de sesión se recupera sin necesidad de solicitar repetitivamente las credenciales del usuario. Al presionar "Cerrar sesión", el registro local es destruido y el usuario es redirigido a la pantalla de Login invalidando la sesión en memoria.

---

## 6. Evidencia Técnica del Acceso a Datos desde la Aplicación

A continuación se presentan los fragmentos de código y contratos de datos que demuestran la integración funcional de acceso a datos entre Flutter, FastAPI y MySQL:

### 6.1 Contrato de Datos: Inicio de Sesión (`POST /login`)
* **Petición del Cliente (Flutter `AuthService`):**
```json
{
  "mail": "aaron@duncan.com",
  "password": "Aaron123*"
}
```
* **Respuesta del Servidor (FastAPI HTTP 200 OK):**
```json
{
  "id_usr": 2,
  "nom_usr": "Aaron Alexander Paniagua Chávez",
  "mail": "aaron@duncan.com",
  "dir_usr": "Corregidora, Querétaro",
  "tip_usu": 2,
  "foto_perfil": null
}
```

### 6.2 Código Fuente: Verificación Criptográfica en el Backend (`main.py`)
```python
@app.post("/login", response_model=UsuarioRespuesta)
def iniciar_sesion(datos: LoginRequest, db: Session = Depends(obtener_sesion)):
    correo = datos.mail.strip().lower()
    usuario = db.scalar(select(Usuario).where(Usuario.mail == correo))

    if usuario is None or not verificar_password(datos.password, usuario.pass_hash):
        raise HTTPException(
            status_code=401,
            detail="Correo o contraseña incorrectos",
        )
    return usuario
```

### 6.3 Código Fuente: Creación y Lectura de Comentarios (`main.py` y `post_detail_page.dart`)
* **Backend: Endpoint con Cruce de Datos (JOIN) para Obtener el Autor:**
```python
@app.get("/comentarios", response_model=list[ComentarioRespuesta])
def listar_comentarios(blog_id: int | None = None, db: Session = Depends(obtener_sesion)):
    query = (
        select(Comentario, Usuario.nom_usr)
        .outerjoin(Usuario, Comentario.usr_id == Usuario.id_usr)
        .order_by(Comentario.id_com.asc())
    )
    if blog_id is not None:
        query = query.where(Comentario.blog_id == blog_id)

    resultados = db.execute(query).all()
    return [
        ComentarioRespuesta(
            id_com=com.id_com,
            comentario=com.comentario,
            fecha=com.fecha,
            estatus=com.estatus,
            usr_id=com.usr_id,
            blog_id=com.blog_id,
            autor=autor_nombre or "Usuario registrado",
        )
        for com, autor_nombre in resultados
    ]
```

* **Frontend: Consumo y Renderizado Reactivo en Flutter:**
```dart
Future<void> _enviarComentario() async {
  final texto = _comentarioController.text.trim();
  if (texto.isEmpty) return;

  final nuevoComentario = ComentarioModel(
    id: 0,
    comentario: texto,
    fecha: DateTime.now().toIso8601String(),
    estatus: 1,
    usuarioId: _usuario['id_usr'] ?? 1,
    blogId: widget.post.id,
    autor: _usuario['nom_usr'] ?? 'Usuario',
  );

  await _comentarioService.agregarComentario(nuevoComentario);
  _comentarioController.clear();
  _recargarComentarios();
}
```

---

## 7. Reflexión sobre el Proceso de Desarrollo

El desarrollo del proyecto **Duncan Mascotas** representó una valiosa experiencia de integración técnica en la que se aplicaron de forma práctica los conceptos vistos a lo largo de la materia de Aplicaciones Móviles.

Entre los principales retos técnicos enfrentados y resueltos con éxito destacan:
1. **Desacoplamiento y Sincronización Cliente-Servidor:** Uno de los desafíos fundamentales fue coordinar el formato de transmisión de datos para publicaciones con imágenes. Mientras que los formularios web tradicionales emplean codificación Multipart, las aplicaciones móviles modernas frecuentemente manejan cadenas en Base64 procedentes del sensor de cámara o selectores de archivos. La solución consistió en diseñar un endpoint en FastAPI capaz de inspeccionar dinámicamente el `Content-Type` de la solicitud, decodificar los flujos Base64 hacia archivos físicos en el servidor y retornar rutas normalizadas para el consumo en Flutter.
2. **Coherencia en Tipos de Datos y Compatibilidad de Motores:** En la base de datos relacional MySQL, el campo de rol se modeló como entero (`tip_usu INT`), mientras que en etapas tempranas se contemplaba el uso de cadenas de texto. Mediante validadores Pydantic con la directiva `@field_validator(mode="before")`, logramos unificar el parseo de datos para que la API acepte y devuelva valores consistentes sin provocar inconsistencias en las sentencias preparadas de MySQL.
3. **Optimización del Flujo de Trabajo mediante Google Chrome:** La posibilidad de compilar y probar la aplicación Flutter en web mediante Chrome agilizó enormemente los ciclos de prueba e iteración, reduciendo los tiempos de arranque y eliminando la dependencia obligatoria de emuladores Android pesados que demandan altos recursos de hardware.

En conclusión, el proyecto demuestra cómo la combinación de un backend robusto en FastAPI, un frontend multiplataforma en Flutter y una base de datos relacional sólida en MySQL permite construir soluciones de software seguras, modulares y escalables, listas para responder a requerimientos reales de la industria del software.
