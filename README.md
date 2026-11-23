# Proyecto: Duncan Mascotas - Plataforma Multiplataforma de Blog y Comunidad Canina

Universidad Tecnologica de Queretaro (UTEQ)  
Carrera: Tecnologias de la Informacion  
Licenciatura en Ingenieria en Tecnologias de la Informacion e Innovacion Digital  
Materia: Aplicaciones Moviles  
Grupo: LITIID014  
Docente: Adriana Y Contreras Alvarez  
Evaluacion: Unidad 3  

Integrantes del equipo:
* Aaron Alexander Paniagua Chavez
* David Hernandez Gonzalez

---

## 1. Descripcion General del Proyecto

Duncan Mascotas es una plataforma de software multiplataforma disenada bajo una arquitectura cliente-servidor desacoplada. El sistema permite la divulgacion de articulos de bienestar, nutricion, adiestramiento y paseos caninos, facilitando la interaccion activa de los usuarios mediante la lectura de articulos, publicacion de entradas, insercion de comentarios en tiempo real y gestion de perfiles con soporte multimedia y geolocalizacion.

La solucion esta compuesta por tres componentes fundamentales:
1. Base de datos relacional: Gestionada con MySQL Server (motor InnoDB, codificacion UTF-8 / utf8mb4), garantizando integridad referencial, transaccionalidad mediante llaves foraneas y eliminacion en cascada.
2. Backend (API REST): Desarrollado en Python con el framework FastAPI y servidor ASGI Uvicorn. Implementa persistencia con el ORM SQLAlchemy 2.0, validacion de datos mediante Pydantic y encriptacion criptografica de contraseñas mediante BCrypt y Argon2.
3. Frontend (Aplicacion Multiplataforma): Desarrollado con el SDK de Flutter y lenguaje Dart, optimizado para ejecutarse en entornos web modernos mediante Google Chrome y en dispositivos moviles Android/iOS sin modificaciones en la base de codigo.

---

## 2. Requisitos Previos del Sistema

Antes de iniciar con el despliegue del proyecto, asegurese de contar con una computadora con sistema operativo Windows (10 o 11), Linux o macOS y los siguientes paquetes instalados:

1. Visual Studio Code: Editor de codigo fuente recomendado.
2. Google Chrome: Navegador web recomendado y requerido para ejecutar y depurar la aplicacion Flutter sin necesidad de configurar emuladores pesados.
3. Git: Sistema de control de versiones para clonar y sincronizar el repositorio.
4. Python 3.10 o superior (preferentemente Python 3.11).
5. MySQL Server 8.0 o paquete XAMPP (con servicio MySQL activado).
6. Flutter SDK (version estable 3.x o superior) con soporte para plataforma web activado.

---

## 3. Guia de Instalacion de Herramientas desde Cero

Si esta configurando una computadora nueva o desde cero, realice las siguientes instalaciones en el orden indicado:

### 3.1 Instalacion de Visual Studio Code
1. Ingrese al sitio oficial: https://code.visualstudio.com
2. Descargue el instalador para su sistema operativo (por ejemplo, User Installer para Windows de 64 bits).
3. Ejecute el instalador, acepte los terminos de licencia y marque las casillas para agregar la opcion "Abrir con Code" al menu contextual y agregar VS Code al PATH del sistema.
4. Finalice la instalacion e inicie Visual Studio Code.
5. Dentro de VS Code, dirijase a la pestaña de Extensiones (Ctrl + Shift + X) e instale las siguientes extensiones recomendadas:
   * Flutter (desarrollada por Dart Code)
   * Dart (se instala automaticamente con la de Flutter)
   * Python (desarrollada por Microsoft)

### 3.2 Instalacion de Google Chrome
1. Ingrese a: https://www.google.com/chrome/
2. Descargue e instale Google Chrome en su computadora.
3. Justificacion tecnica del uso de Google Chrome: Flutter cuenta con soporte nativo de primera clase para la web a traves de Chrome. Esto permite compilar y ejecutar la aplicacion de forma inmediata, aprovechando el motor V8 y las herramientas para desarrolladores de Chrome. Al utilizar Chrome se evita la obligacion de descargar Android Studio, configurar maquinas virtuales pesadas que consumen mas de 8 GB de memoria RAM o habilitar tecnologias de virtualizacion en la BIOS (VT-x o AMD-V), haciendo que el proyecto sea ejecutable en cualquier computadora de manera rapida y eficiente.

### 3.3 Instalacion de Git
1. Ingrese a: https://git-scm.com/download/win
2. Descargue y ejecute el instalador de Git.
3. Durante el asistente de instalacion, mantenga las opciones predeterminadas y confirme que la opcion de agregar Git a la linea de comandos este seleccionada.
4. Al finalizar, abra una terminal (PowerShell o CMD) y verifique la instalacion ejecutando:
   git --version

### 3.4 Instalacion de Python
1. Ingrese a: https://www.python.org/downloads/
2. Descargue la version estable mas reciente de Python 3 (3.10, 3.11 o 3.12).
3. Importante: Al ejecutar el instalador en Windows, marque obligatoriamente la casilla inferior que indica "Add python.exe to PATH" antes de dar clic en "Install Now".
4. Verifique la instalacion en una ventana de terminal con los siguientes comandos:
   python --version
   pip --version

### 3.5 Instalacion y Configuracion de MySQL
Puede utilizar MySQL Server oficial o XAMPP:

* Opcion A (MySQL Server Oficial):
  1. Descargue el instalador MySQL Installer Community desde: https://dev.mysql.com/downloads/installer/
  2. Instale MySQL Server 8.0 y configure una contraseña para el usuario root (por ejemplo, anote la contraseña que elija; en el archivo de configuracion se utiliza por defecto o se personaliza en el archivo .env).
  3. Asegurese de que el servicio de MySQL este iniciado en el puerto estandar 3306.

* Opcion B (Mediante XAMPP):
  1. Descargue XAMPP desde: https://www.apachefriends.org
  2. Instale el paquete y abra el Panel de Control de XAMPP.
  3. De clic en el boton "Start" junto al modulo de MySQL para iniciar el servicio en el puerto 3306.

### 3.6 Instalacion de Flutter SDK
1. Ingrese a la documentacion oficial de Flutter: https://docs.flutter.dev/get-started/install/windows
2. Descargue el archivo comprimido del SDK de Flutter (flutter_windows_x.x.x-stable.zip).
3. Extraiga la carpeta en una ruta accesible que no requiera permisos elevados de administrador, por ejemplo: C:\src\flutter
4. Agregue la ruta del directorio bin de Flutter a las Variables de Entorno del sistema:
   * En el buscador de Windows, escriba "variables de entorno" y seleccione "Editar las variables de entorno del sistema".
   * De clic en "Variables de entorno...".
   * En la seccion "Variables del sistema", busque la variable `Path`, seleccionela y de clic en "Editar".
   * De clic en "Nuevo" y agregue la ruta completa, por ejemplo: C:\src\flutter\bin
   * De clic en "Aceptar" en todas las ventanas.
5. Cierre y vuelva a abrir su terminal. Ejecute el comando de diagnostico de Flutter:
   flutter doctor
6. Habilite el soporte para desarrollo web ejecutando:
   flutter config --enable-web

---

## 4. Obtencion del Codigo Fuente del Proyecto

Para descargar el proyecto en su computadora, elija uno de los dos metodos siguientes:

### Metodo 1: Clonar mediante Git (Recomendado)
Abra una terminal en la carpeta donde desea ubicar el proyecto (por ejemplo, en su escritorio o carpeta de proyectos) y ejecute:
```bash
git clone https://github.com/dvdhgon/app_movil.git
cd app_movil
```

### Metodo 2: Descargar archivo ZIP
1. Ingrese a la pagina del repositorio en GitHub: https://github.com/dvdhgon/app_movil
2. De clic en el boton verde "Code" y seleccione "Download ZIP".
3. Descomprima el archivo descargado en la ubicacion de su preferencia.
4. Abra la carpeta resultante con Visual Studio Code.

---

## 5. Paso a Paso para la Puesta en Marcha del Sistema

El despliegue consta de tres fases sencillas: base de datos, backend y frontend.

### FASE 1: Configuracion de la Base de Datos MySQL

1. Abra su gestor de MySQL preferido (MySQL Workbench, HeidiSQL, DBeaver, la consola de comandos de MySQL o phpMyAdmin en http://localhost/phpmyadmin).
2. Localice el archivo `bd.sql` ubicado en la raiz del repositorio o dentro de la carpeta `Flutter_project-main/backend_API/bd.sql`.
3. Abra el archivo `bd.sql` en su gestor y ejecute la totalidad de sus instrucciones.
4. El script realizara de forma automatica:
   * Creacion de la base de datos `bd_aplicacion_movil`.
   * Creacion de la tabla `usuario` con columnas para control de roles, datos personales y ruta de fotografia de perfil.
   * Creacion de la tabla `blog` para las publicaciones y articulos.
   * Creacion de la tabla `comentarios` con restricciones de llave foranea e integridad referencial.
   * Inyeccion de usuarios de prueba con contraseñas encriptadas mediante algoritmo criptografico seguro BCrypt.
   * Insercion de entradas tematicas sobre cuidado canino y comentarios de ejemplo.

### FASE 2: Configuracion y Ejecucion del Backend (FastAPI)

1. En Visual Studio Code, abra una nueva terminal integrada (Terminal -> Nueva terminal) o abra una ventana de PowerShell / CMD.
2. Navegue al directorio del backend:
```bash
cd Flutter_project-main/backend_API
```
*(Nota: si los archivos estan en la carpeta raiz de su copia local, navegue directamente a la carpeta `backend_API`).*

3. Cree un entorno virtual de Python aislado para no generar conflictos de dependencias en su sistema:
```bash
python -m venv venv
```

4. Active el entorno virtual segun su sistema operativo:
   * En Windows PowerShell:
     ```powershell
     .\venv\Scripts\Activate.ps1
     ```
     *En caso de presentarse una advertencia sobre directivas de ejecucion en PowerShell, ejecute previamente:*
     ```powershell
     Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
     ```
     *y vuelva a ejecutar `.\venv\Scripts\Activate.ps1`.*
   * En Windows CMD (Simbolo del sistema):
     ```cmd
     venv\Scripts\activate.bat
     ```
   * En Linux o macOS:
     ```bash
     source venv/bin/activate
     ```

5. Instale los paquetes y librerias necesarias mediante pip:
```bash
pip install -r requirements.txt
```

6. Verifique el archivo de variables de entorno `.env`:
   Asegurese de que exista el archivo `.env` dentro de la carpeta `backend_API`. Si no existe, copie el archivo de ejemplo `.env.example`:
   ```bash
   cp .env.example .env
   ```
   Contenido del archivo `.env`:
   ```env
   DB_HOST=localhost
   DB_PORT=3306
   DB_USER=root
   DB_PASSWORD=4591096767
   DB_NAME=bd_aplicacion_movil
   ```
   *(Ajuste los valores de `DB_USER` y `DB_PASSWORD` en caso de que su instalacion local de MySQL tenga credenciales distintas).*

7. Inicie el servidor de desarrollo de la API con Uvicorn:
```bash
uvicorn main:app --reload --host 127.0.0.1 --port 8000
```

8. Comprobacion de funcionamiento:
   Abra su navegador web e ingrese a las siguientes direcciones:
   * Estado del servicio: http://127.0.0.1:8000
   * Documentacion interactiva Swagger UI: http://127.0.0.1:8000/docs
   * Feed de publicaciones en formato JSON: http://127.0.0.1:8000/blog

Mantenga esta terminal abierta para que el servidor backend continue en ejecucion atendiendo las peticiones.

---

### FASE 3: Configuracion y Ejecucion de la Aplicacion Flutter

1. Abra una segunda pestaña o ventana de terminal en Visual Studio Code.
2. Navegue al directorio del proyecto de Flutter:
```bash
cd Flutter_project-main/flutter_application_3
```

3. Descargue y resuelva los paquetes y dependencias del archivo `pubspec.yaml`:
```bash
flutter pub get
```

4. Ejecute la aplicacion en Google Chrome mediante el comando:
```bash
flutter run -d chrome
```

Flutter compilara el codigo Dart y abrira automaticamente una ventana dedicada de Google Chrome con la aplicacion Duncan Mascotas lista para interactuar.

*(Opcional: Si cuenta con un telefono Android conectado por cable USB con depuracion activada o un emulador de Android iniciado, puede ejecutar alternativamente `flutter run` para probar en el dispositivo movil).*

---

## 6. Cuentas de Acceso Preconfiguradas para Evaluacion

El script `bd.sql` inyecta las siguientes cuentas de prueba con contraseñas encriptadas mediante BCrypt para facilitar la revision completa de las funcionalidades y roles del sistema:

| Nombre de Usuario | Correo Electronico | Contraseña | Rol en el Sistema | Permisos y Vistas |
| :--- | :--- | :--- | :--- | :--- |
| Administrador General | admin@duncan.com | Admin123* | 1 (Administrador) | Acceso total: Gestion de usuarios (CRUD), creacion de blogs, edicion de perfil, consulta de mapa, visualizacion de comentarios. |
| Aaron Alexander Paniagua Chavez | aaron@duncan.com | Aaron123* | 2 (Usuario / Autor) | Consulta de blogs, creacion de nuevas entradas con imagen, redaccion y lectura de comentarios, edicion de perfil. |
| David Hernandez Gonzalez | david@duncan.com | David123* | 2 (Usuario / Autor) | Consulta de blogs, creacion de nuevas entradas, redaccion de comentarios, edicion de perfil y cambio de contraseña. |
| Adriana Y Contreras Alvarez | adriana@uteq.edu.mx | Uteq2026* | 1 (Docente / Administrador) | Perfil creado para la evaluacion docente con permisos completos de administracion. |

---

## 7. Estructura del Repositorio

El proyecto se encuentra organizado de manera modular y limpia:

```text
app_movil/
├── bd.sql                                  # Script maestro de base de datos MySQL (estructura y datos semilla)
├── README.md                               # Documentacion completa de instalacion y uso paso a paso
├── diagramas/                              # Diagramas de software editables en formato Draw.io (XML)
│   ├── diagrama_clases.drawio             # Diagrama de clases de modelos backend, frontend y servicios
│   ├── diagrama_entidad_relacion.drawio    # Modelo entidad-relacion relacional de la base de datos
│   └── diagrama_arquitectura.drawio        # Arquitectura cliente-servidor y flujo de datos
├── reportes/                               # Reportes tecnicos digitales para entrega academica
│   ├── Reporte_Tecnico_Evaluacion_Unidad_3.md   # Reporte tecnico en formato Markdown
│   └── Reporte_Tecnico_Evaluacion_Unidad_3.docx # Documento formal de Word listo para conversion a PDF
├── video_guia/
│   └── Guia_Grabacion_Video_Demostrativo.md     # Guion paso a paso para la grabacion del video de evidencia
└── Flutter_project-main/                   # Codigo fuente completo del proyecto
    ├── backend_API/                        # Servidor REST con FastAPI
    │   ├── main.py                         # Definicion de endpoints, logica de negocio y CORS
    │   ├── database.py                     # Conexion con SQLAlchemy y PyMySQL a MySQL
    │   ├── models.py                       # Entidades ORM (Usuario, Blog, Comentario)
    │   ├── schemas.py                      # DTOs y esquemas de validacion Pydantic
    │   ├── requirements.txt                # Lista de librerias Python necesarias
    │   ├── .env                            # Archivo de configuracion de credenciales locales
    │   ├── .env.example                    # Plantilla de configuracion de entorno
    │   └── uploads/                        # Directorio para almacenamiento de imagenes subidas
    └── flutter_application_3/              # Aplicacion cliente en Flutter
        ├── pubspec.yaml                    # Dependencias y configuracion de paquetes de Flutter
        └── lib/
            ├── main.dart                   # Punto de entrada de la aplicacion y temas
            ├── models/                     # Modelos de datos en Dart (User, Post, Comentario)
            │   └── services/               # Servicios HTTP desacoplados (Auth, User, Post, Comentario)
            ├── screens/                    # Pantallas de la aplicacion (Login, Blog, Detalle, Usuarios, Perfil, Mapa)
            └── widgets/                    # Componentes reutilizables de interfaz de usuario
```

---

## 8. Principales Rutas de la API REST

A continuacion se detallan los endpoints provistos por el backend FastAPI:

* Autenticacion:
  * `POST /login`: Validacion de credenciales de usuario con comparacion segura de hash BCrypt / Argon2. Retorna el objeto del usuario autenticado y su rol.
* Gestion de Usuarios:
  * `GET /usuarios`: Obtiene el listado completo de usuarios registrados.
  * `GET /usuarios/{id}`: Obtiene los detalles de un usuario especifico.
  * `POST /usuarios`: Registra un nuevo usuario con contraseña encriptada.
  * `PUT /usuarios/{id}`: Actualiza informacion personal, direccion o contraseña de un usuario.
  * `POST /usuarios/{id}/foto`: Carga binaria de fotografia de perfil para el usuario.
  * `DELETE /usuarios/{id}`: Elimina la cuenta de un usuario y sus comentarios asociados.
* Publicaciones de Blog:
  * `GET /blog` o `GET /blogs`: Devuelve la lista ordenada de articulos publicados.
  * `GET /blog/{id}`: Obtiene los datos detallados de un articulo.
  * `POST /blog`: Crea un nuevo articulo admitiendo carga por JSON (con imagen en Base64 o URL) o por formulario Multipart.
* Comentarios:
  * `GET /comentarios`: Obtiene comentarios globales o filtrados por publicacion (`?blog_id={id}`). Incluye el nombre del autor asociado.
  * `POST /comentarios`: Registra un nuevo comentario validando la existencia de la publicacion y del usuario emisor.

---

## 9. Solucion a Problemas Frecuentes

1. Error: "Access denied for user 'root'@'localhost'"
   * Causa: La contraseña de MySQL configurada en su equipo difiere de la especificada en el archivo `.env`.
   * Solucion: Abra el archivo `backend_API/.env` y modifique la linea `DB_PASSWORD=su_contraseña_real`.

2. Error: "La ejecucion de scripts esta deshabilitada en este sistema" (PowerShell al activar venv)
   * Causa: Politica de ejecucion restrictiva de PowerShell en Windows.
   * Solucion: En la ventana de PowerShell, ejecute `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass` y vuelva a activar el entorno virtual con `.\venv\Scripts\Activate.ps1`.

3. Error: "No se puede conectar con el servidor" desde Flutter
   * Causa: El backend de FastAPI no esta en ejecucion en el puerto 8000.
   * Solucion: Confirme que la terminal del backend muestre `Uvicorn running on http://127.0.0.1:8000`.

4. Error con librerias faltantes en Python
   * Solucion: Asegurese de haber activado el entorno virtual (`(venv)`) y ejecute `pip install -r requirements.txt`.
