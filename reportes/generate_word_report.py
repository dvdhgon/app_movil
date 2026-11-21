import docx
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.oxml import parse_xml
from docx.oxml.ns import nsdecls

doc = Document()

# Set page margins (2.5 cm approx 1 inch)
for section in doc.sections:
    section.top_margin = Inches(1)
    section.bottom_margin = Inches(1)
    section.left_margin = Inches(1)
    section.right_margin = Inches(1)

COLOR_VINO = RGBColor(114, 47, 55)    # #722F37
COLOR_DORADO = RGBColor(212, 175, 55) # #D4AF37
COLOR_TEXTO = RGBColor(40, 40, 40)
HEX_VINO = '722F37'
HEX_DORADO = 'D4AF37'
HEX_GRIS_CLARO = 'F8F9FA'

def set_cell_background(cell, hex_color):
    tcPr = cell._element.get_or_add_tcPr()
    shd = parse_xml(f'<w:shd {nsdecls("w")} w:fill="{hex_color}"/>')
    tcPr.append(shd)

def set_cell_margins(cell, top=120, bottom=120, left=150, right=150):
    tcPr = cell._element.get_or_add_tcPr()
    tcMar = parse_xml(f'<w:tcMar {nsdecls("w")}><w:top w:w="{top}" w:type="dxa"/><w:bottom w:w="{bottom}" w:type="dxa"/><w:left w:w="{left}" w:type="dxa"/><w:right w:w="{right}" w:type="dxa"/></w:tcMar>')
    tcPr.append(tcMar)

# ==================== PORTADA ====================
p_inst = doc.add_paragraph()
p_inst.alignment = WD_ALIGN_PARAGRAPH.CENTER
r_inst = p_inst.add_run('UNIVERSIDAD TECNOLÓGICA DE QUERÉTARO\n')
r_inst.font.name = 'Arial'
r_inst.font.size = Pt(16)
r_inst.font.bold = True
r_inst.font.color.rgb = COLOR_VINO

r_subinst = p_inst.add_run('DIVISIÓN DE TECNOLOGÍAS DE LA INFORMACIÓN Y COMUNICACIÓN\nLICENCIATURA EN INGENIERÍA EN TECNOLOGÍAS DE LA INFORMACIÓN E INNOVACIÓN DIGITAL')
r_subinst.font.name = 'Arial'
r_subinst.font.size = Pt(11)
r_subinst.font.color.rgb = RGBColor(90, 37, 43)

p_linea = doc.add_paragraph()
p_linea.alignment = WD_ALIGN_PARAGRAPH.CENTER
r_lin = p_linea.add_run('━' * 45)
r_lin.font.color.rgb = COLOR_DORADO
r_lin.font.bold = True

p_tema = doc.add_paragraph()
p_tema.alignment = WD_ALIGN_PARAGRAPH.CENTER
p_tema.paragraph_format.space_before = Pt(30)
p_tema.paragraph_format.space_after = Pt(12)

r_tema = p_tema.add_run('REPORTE TÉCNICO DE PROYECTO INTEGRAL\n')
r_tema.font.name = 'Arial'
r_tema.font.size = Pt(20)
r_tema.font.bold = True
r_tema.font.color.rgb = COLOR_VINO

r_caso = p_tema.add_run('CASO PRÁCTICO: DUNCAN MASCOTAS\nSISTEMA DE BLOG MULTIPLATAFORMA (FLUTTER + FASTAPI + MYSQL)\n')
r_caso.font.name = 'Arial'
r_caso.font.size = Pt(14)
r_caso.font.bold = True
r_caso.font.color.rgb = RGBColor(60, 60, 60)

r_eval = p_tema.add_run('EVALUACIÓN UNIDAD 3')
r_eval.font.name = 'Arial'
r_eval.font.size = Pt(13)
r_eval.font.bold = True
r_eval.font.color.rgb = COLOR_DORADO

# Cuadro destacado con la leyenda requerida
table_leyenda = doc.add_table(rows=1, cols=1)
table_leyenda.alignment = WD_TABLE_ALIGNMENT.CENTER
cell_l = table_leyenda.rows[0].cells[0]
set_cell_background(cell_l, 'FFF8E7')
set_cell_margins(cell_l, top=160, bottom=160, left=250, right=250)

p_l = cell_l.paragraphs[0]
p_l.alignment = WD_ALIGN_PARAGRAPH.CENTER
r_l_tit = p_l.add_run('Actividad para alcanzar 10 Puntos\n')
r_l_tit.font.name = 'Arial'
r_l_tit.font.size = Pt(13)
r_l_tit.font.bold = True
r_l_tit.font.color.rgb = COLOR_VINO

r_l_desc = p_l.add_run('Evidencias de Aprendizaje: Reporte Digital Técnico (30 Puntos / 30%) y Repositorio Público GitHub (70 Puntos / 70%)')
r_l_desc.font.name = 'Arial'
r_l_desc.font.size = Pt(9.5)
r_l_desc.font.italic = True
r_l_desc.font.color.rgb = RGBColor(80, 80, 80)

p_meta = doc.add_paragraph()
p_meta.paragraph_format.space_before = Pt(36)
p_meta.paragraph_format.line_spacing = 1.3

runs_meta = [
    ('Materia: ', True, COLOR_VINO),
    ('Aplicaciones Móviles\n', False, COLOR_TEXTO),
    ('Grupo: ', True, COLOR_VINO),
    ('LITIID014\n', False, COLOR_TEXTO),
    ('Docente: ', True, COLOR_VINO),
    ('Adriana Y Contreras Alvarez\n', False, COLOR_TEXTO),
    ('Alumnos: \n', True, COLOR_VINO),
    ('  • Aaron Alexander Paniagua Chávez (Matrícula: 2025310418)\n  • David Hernández González\n', False, COLOR_TEXTO),
    ('Repositorio GitHub: ', True, COLOR_VINO),
    ('https://github.com/dvdhgon/app_movil\n', False, RGBColor(33, 150, 243)),
    ('Fecha de Elaboración: ', True, COLOR_VINO),
    ('Noviembre de 2026 - Santiago de Querétaro, Qro.', False, COLOR_TEXTO),
]
for text, bold, color in runs_meta:
    r = p_meta.add_run(text)
    r.font.name = 'Arial'
    r.font.size = Pt(11)
    r.font.bold = bold
    r.font.color.rgb = color

doc.add_page_break()

# ==================== ENCABEZADO Y PIE DE PÁGINA ====================
sec_body = doc.sections[0]
header = sec_body.header
p_head = header.paragraphs[0]
p_head.text = 'Duncan Mascotas | Reporte Técnico de Requerimientos PS-FO-002 | Edición 1'
p_head.alignment = WD_ALIGN_PARAGRAPH.RIGHT
p_head.style.font.name = 'Arial'
p_head.style.font.size = Pt(8.5)
p_head.style.font.color.rgb = RGBColor(120, 120, 120)

footer = sec_body.footer
p_foot = footer.paragraphs[0]
p_foot.text = 'Universidad Tecnológica de Querétaro (UTEQ) - Licenciatura en ITIID'
p_foot.alignment = WD_ALIGN_PARAGRAPH.CENTER
p_foot.style.font.name = 'Arial'
p_foot.style.font.size = Pt(8.5)
p_foot.style.font.color.rgb = RGBColor(120, 120, 120)

def add_custom_heading(text, level=1):
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(16)
    p.paragraph_format.space_after = Pt(6)
    p.paragraph_format.keep_with_next = True
    r = p.add_run(text)
    r.font.name = 'Arial'
    r.font.bold = True
    if level == 1:
        r.font.size = Pt(14)
        r.font.color.rgb = COLOR_VINO
        p_sub = doc.add_paragraph()
        p_sub.paragraph_format.space_after = Pt(8)
        r_lin = p_sub.add_run('━' * 35)
        r_lin.font.color.rgb = COLOR_DORADO
        r_lin.font.size = Pt(10)
    elif level == 2:
        r.font.size = Pt(12)
        r.font.color.rgb = RGBColor(90, 37, 43)
    else:
        r.font.size = Pt(11)
        r.font.color.rgb = COLOR_TEXTO
    return p

def add_body_p(text, bold_prefix='', italic=False):
    p = doc.add_paragraph()
    p.paragraph_format.space_after = Pt(6)
    p.paragraph_format.line_spacing = 1.15
    if bold_prefix:
        r_pre = p.add_run(bold_prefix)
        r_pre.font.name = 'Arial'
        r_pre.font.size = Pt(10)
        r_pre.font.bold = True
        r_pre.font.color.rgb = COLOR_VINO
    r = p.add_run(text)
    r.font.name = 'Arial'
    r.font.size = Pt(10)
    r.font.italic = italic
    r.font.color.rgb = COLOR_TEXTO
    return p

# 1. Introducción
add_custom_heading('1. Introducción y Contexto del Caso Práctico', 1)
add_body_p('El presente proyecto técnico corresponde a la Evaluación de la Unidad 3 de la materia de Aplicaciones Móviles en la Universidad Tecnológica de Querétaro (UTEQ). El objetivo principal consistió en diseñar, desarrollar y desplegar una plataforma multiplataforma para el blog y comunidad canina "Duncan Mascotas", articulando de forma modular una aplicación cliente en Flutter, una API RESTful desarrollada con FastAPI en Python y un modelo de datos persistido en el gestor relacional MySQL.')
add_body_p('La solución resuelve la necesidad de difundir contenidos especializados en salud, adiestramiento, nutrición y paseos caninos, permitiendo a los usuarios registrarse, consultar publicaciones con recursos multimedia, crear entradas y participar interactivamente mediante comentarios validados en tiempo real.')

# 2. Diagramas de Clases y Modelo de Datos
add_custom_heading('2. Diagramas de Clases y Modelo de Datos Relacional', 1)
add_body_p('El diseño arquitectónico se fundamenta en el desacoplamiento de capas y en la integridad de datos bajo la tercera forma normal (3FN).')

add_custom_heading('2.1 Modelo Relacional de Base de Datos (MySQL)', 2)
add_body_p('La base de datos "bd_aplicacion_movil" opera bajo el motor InnoDB con codificación UTF-8 internacional (utf8mb4_unicode_ci), estructurada en las siguientes tres entidades relacionales:')

t_bd = doc.add_table(rows=1, cols=4)
t_bd.alignment = WD_TABLE_ALIGNMENT.CENTER
headers_bd = ['Tabla', 'Columna / Atributo', 'Tipo de Dato', 'Descripción y Restricción']
for i, h in enumerate(headers_bd):
    cell = t_bd.rows[0].cells[i]
    set_cell_background(cell, HEX_VINO)
    set_cell_margins(cell, top=100, bottom=100, left=100, right=100)
    p = cell.paragraphs[0]
    r = p.add_run(h)
    r.font.name = 'Arial'
    r.font.bold = True
    r.font.size = Pt(9)
    r.font.color.rgb = RGBColor(255, 255, 255)

filas_bd = [
    ('usuario', 'id_usr', 'INT AUTO_INC', 'Clave Primaria (PK). Identificador único.'),
    ('usuario', 'nom_usr', 'VARCHAR(100)', 'Nombre completo del usuario.'),
    ('usuario', 'mail', 'VARCHAR(150)', 'Correo electrónico único (UNIQUE). Credencial de acceso.'),
    ('usuario', 'pass', 'VARCHAR(255)', 'Hash criptográfico irreversible (BCrypt / Argon2).'),
    ('usuario', 'dir_usr', 'VARCHAR(200)', 'Dirección o residencia del usuario.'),
    ('usuario', 'tip_usu', 'INT DEFAULT 2', 'Nivel de rol (1 = Administrador, 2 = Usuario / Autor).'),
    ('usuario', 'foto_perfil', 'VARCHAR(500)', 'Ruta local del servidor hacia la foto (/uploads/...).'),
    ('blog', 'id_blog', 'INT AUTO_INC', 'Clave Primaria (PK). Identificador de la publicación.'),
    ('blog', 'titulo', 'VARCHAR(150)', 'Título del artículo o publicación.'),
    ('blog', 'desc', 'TEXT', 'Cuerpo y contenido textual del artículo.'),
    ('blog', 'img', 'VARCHAR(500)', 'Ruta relativa de imagen (/uploads/...) o URL HTTP.'),
    ('blog', 'tags', 'VARCHAR(255)', 'Etiquetas temáticas separadas por comas.'),
    ('comentarios', 'id_com', 'INT AUTO_INC', 'Clave Primaria (PK). Identificador del comentario.'),
    ('comentarios', 'comentario', 'TEXT', 'Mensaje redactado por el usuario.'),
    ('comentarios', 'fecha', 'DATETIME', 'Fecha y hora de registro (DEFAULT CURRENT_TIMESTAMP).'),
    ('comentarios', 'estatus', 'INT DEFAULT 1', 'Bandera de estado (1 = Aprobado, 0 = Oculto).'),
    ('comentarios', 'usr_id', 'INT (FK)', 'Clave foránea hacia usuario.id_usr (ON DELETE CASCADE).'),
    ('comentarios', 'blog_id', 'INT (FK)', 'Clave foránea hacia blog.id_blog (ON DELETE CASCADE).'),
]

for row_idx, data in enumerate(filas_bd):
    row = t_bd.add_row()
    bg = HEX_GRIS_CLARO if row_idx % 2 == 1 else 'FFFFFF'
    for c_idx, val in enumerate(data):
        cell = row.cells[c_idx]
        set_cell_background(cell, bg)
        set_cell_margins(cell, top=80, bottom=80, left=80, right=80)
        p = cell.paragraphs[0]
        r = p.add_run(val)
        r.font.name = 'Arial'
        r.font.size = Pt(8.5)
        if c_idx == 0:
            r.font.bold = True
            r.font.color.rgb = COLOR_VINO

add_body_p('Integridad Referencial: La relación entre usuario y comentarios es de 1 a N, al igual que la relación entre blog y comentarios. Ambas llaves foráneas cuentan con la restricción ON DELETE CASCADE, garantizando consistencia relacional.', italic=True)

add_custom_heading('2.2 Diagrama de Clases del Sistema', 2)
add_body_p('El sistema implementa clases de dominio tanto en el servidor como en el cliente móvil:')
add_body_p('• Capa Backend (ORM SQLAlchemy y DTOs Pydantic): Clases Usuario, Blog y Comentario, complementadas por esquemas de validación UsuarioCrear, UsuarioRespuesta, LoginRequest, BlogCrear, BlogRespuesta y ComentarioRespuesta.')
add_body_p('• Capa Frontend (Modelos y Servicios Dart/Flutter): Clases UserModel, PostModel y ComentarioModel, las cuales encapsulan la lógica de parseo desde/hacia JSON. Estas son consumidas por los servicios HTTP desacoplados: AuthService, UserService, PostService y ComentarioService.')
add_body_p('Nota de entrega: Los archivos de diagrama vectoriales editables completos se incluyen en la carpeta /diagramas del repositorio: diagrama_clases.drawio, diagrama_entidad_relacion.drawio y diagrama_arquitectura.drawio.')

# 3. Justificación de Sensores
add_custom_heading('3. Justificación del Uso de Sensores y Recursos Multimedia', 1)
add_body_p('De conformidad con los criterios de evaluación de la asignatura, el proyecto integra el uso de hardware del dispositivo móvil:')
add_body_p('El hardware de captura fotográfica (cámara) y el acceso a la galería local se implementan a través del plugin image_picker. Su uso está plenamente justificado en dos flujos funcionales esenciales: (1) En ProfilePage, permitiendo al usuario capturar su fotografía de perfil en tiempo real o seleccionarla del álbum del dispositivo; y (2) En AddBlogPage, permitiendo al autor tomar una fotografía directa del perro, producto o incidencia para ilustrar su nueva entrada en el blog. Las imágenes son optimizadas, redimensionadas y transmitidas hacia el servidor FastAPI mediante peticiones HTTP Multipart o Base64, preservando la resolución adecuada sin degradar la memoria del teléfono.', bold_prefix='Sensor de Cámara y Fototeca (image_picker): ')
add_body_p('En MapaPage, se implementa el sensor de ubicación satelital y el componente interactivo google_maps_flutter. Se justifican en el modelo de negocio de Duncan Mascotas al proporcionar a los dueños de mascotas y paseadores la geolocalización exacta de zonas pet-friendly, áreas de hidratación y parques públicos de la zona metropolitana de Querétaro (Plaza de Armas, Acueducto de Los Arcos, Alameda Hidalgo y Cerro de las Campanas).', bold_prefix='Sensor de Geolocalización y Mapeo GPS (google_maps_flutter): ')

# 4. Librerías y Recursos Multimedia
add_custom_heading('4. Descripción de Recursos Multimedia y Librerías Utilizadas', 1)
add_body_p('La siguiente tabla describe las librerías fundamentales integradas en el proyecto y su función técnica:')

t_lib = doc.add_table(rows=1, cols=3)
t_lib.alignment = WD_TABLE_ALIGNMENT.CENTER
for i, h in enumerate(['Componente / Librería', 'Entorno / Plataforma', 'Propósito y Función Técnica']):
    cell = t_lib.rows[0].cells[i]
    set_cell_background(cell, HEX_VINO)
    set_cell_margins(cell, top=100, bottom=100, left=100, right=100)
    p = cell.paragraphs[0]
    r = p.add_run(h)
    r.font.name = 'Arial'
    r.font.bold = True
    r.font.size = Pt(9)
    r.font.color.rgb = RGBColor(255, 255, 255)

filas_lib = [
    ('FastAPI', 'Backend (Python)', 'Framework web asíncrono para la construcción de la API RESTful de alto rendimiento.'),
    ('SQLAlchemy 2.0', 'Backend (Python)', 'ORM para modelar entidades relacionales, administrar transacciones y pools de conexión.'),
    ('PyMySQL', 'Backend (Python)', 'Conector TCP/IP de bajo nivel para enlazar SQLAlchemy directamente con MySQL Server.'),
    ('BCrypt / pwdlib', 'Backend (Python)', 'Algoritmo criptográfico de salting y derivación de contraseñas de alta seguridad.'),
    ('Pydantic 2.x', 'Backend (Python)', 'Validación estricta y tipada de esquemas DTO para sanitización de peticiones HTTP.'),
    ('Uvicorn', 'Backend (Python)', 'Servidor web ASGI de producción y desarrollo local con soporte de recarga en caliente.'),
    ('http (Dart)', 'Frontend (Flutter)', 'Cliente HTTP asíncrono para consumo de endpoints con cabeceras JSON y timeouts.'),
    ('shared_preferences', 'Frontend (Flutter)', 'Almacenamiento persistente local de la sesión del usuario (usuario_sesion).'),
    ('image_picker', 'Frontend (Flutter)', 'Acceso al sensor físico de la cámara y selector de archivos del sistema operativo.'),
    ('google_maps_flutter', 'Frontend (Flutter)', 'Renderizado de mapas vectoriales y marcadores geográficos en Querétaro.'),
    ('Google Chrome', 'Entorno Ejecución', 'Plataforma web de ejecución de Flutter sin sobrecarga de emuladores pesados.'),
]

for row_idx, data in enumerate(filas_lib):
    row = t_lib.add_row()
    bg = HEX_GRIS_CLARO if row_idx % 2 == 1 else 'FFFFFF'
    for c_idx, val in enumerate(data):
        cell = row.cells[c_idx]
        set_cell_background(cell, bg)
        set_cell_margins(cell, top=80, bottom=80, left=80, right=80)
        p = cell.paragraphs[0]
        r = p.add_run(val)
        r.font.name = 'Arial'
        r.font.size = Pt(8.5)
        if c_idx == 0:
            r.font.bold = True
            r.font.color.rgb = COLOR_VINO

# 5. Seguridad
add_custom_heading('5. Mecanismos de Seguridad Implementados', 1)
add_body_p('El proyecto satisface los requisitos de seguridad más estrictos de la evaluación técnica:')
add_body_p('Las contraseñas de todos los usuarios son sometidas al algoritmo criptográfico BCrypt (bcrypt.hashpw) con una sal (salt) aleatoria de 12 rondas de complejidad. En la base de datos MySQL solo se almacena la cadena hasheada ($2b$12$...). El backend valida el acceso mediante bcrypt.checkpw, un método seguro contra ataques de temporización (timing attacks). Jamás se almacena ni se expone una contraseña en texto claro.', bold_prefix='1. Encriptación Irreversible de Contraseñas: ')
add_body_p('El sistema distingue entre Administrador (Rol 1) y Usuario / Autor (Rol 2). Al autenticarse con Rol 1, la aplicación habilita el acceso exclusivo a la pantalla de gestión de usuarios (CRUD) y el cajón administrativo AdminDrawer. El usuario regular (Rol 2) únicamente puede publicar, consultar entradas del blog y redactar comentarios, impidiendo cualquier escalamiento no autorizado de privilegios.', bold_prefix='2. Control de Acceso Basado en Roles (RBAC): ')
add_body_p('Toda interacción con la base de datos se canaliza a través de consultas parametrizadas de SQLAlchemy. Ninguna entrada proveniente del usuario es concatenada directamente en sentencias SQL, bloqueando de raíz vectores de inyección SQL.', bold_prefix='3. Mitigación de Inyección SQL y Sanitización: ')
add_body_p('Una vez autenticado exitosamente el usuario mediante POST /login, el objeto de sesión validado se persiste localmente en SharedPreferences bajo la clave "usuario_sesion". Al cerrar la aplicación y volver a abrirla, la sesión se mantiene activa de forma segura. Al pulsar "Cerrar sesión", el registro local se destruye y la aplicación redirige forzosamente al Login limpiando la memoria del dispositivo.', bold_prefix='4. Manejo Seguro de Sesión Local: ')

# 6. Evidencias de Acceso a Datos
add_custom_heading('6. Evidencia Técnica del Acceso a Datos desde la App', 1)
add_body_p('A continuación se documentan los contratos de datos y la integración real entre el cliente Flutter y los endpoints de FastAPI:')

t_end = doc.add_table(rows=1, cols=4)
t_end.alignment = WD_TABLE_ALIGNMENT.CENTER
for i, h in enumerate(['Método', 'Ruta / Endpoint', 'Payload / Parámetros', 'Respuesta HTTP']):
    cell = t_end.rows[0].cells[i]
    set_cell_background(cell, HEX_VINO)
    set_cell_margins(cell, top=100, bottom=100, left=100, right=100)
    p = cell.paragraphs[0]
    r = p.add_run(h)
    r.font.name = 'Arial'
    r.font.bold = True
    r.font.size = Pt(9)
    r.font.color.rgb = RGBColor(255, 255, 255)

filas_end = [
    ('POST', '/login', 'JSON: {mail, password}', '200 OK: Objeto UsuarioRespuesta con rol y token/sesión.'),
    ('GET', '/blog', 'Ninguno', '200 OK: Lista de artículos con título, descripción e imagen.'),
    ('POST', '/blog', 'JSON (img base64) o Multipart Form', '201 Created: Entrada creada y ruta de imagen almacenada.'),
    ('GET', '/comentarios', 'Query: ?blog_id={id}', '200 OK: Comentarios de la publicación con nombre del autor.'),
    ('POST', '/comentarios', 'JSON: {comentario, usr_id, blog_id}', '201 Created: Comentario persistido y vinculado a la publicación.'),
    ('GET', '/usuarios', 'Ninguno (Admin)', '200 OK: Listado de usuarios registrados en el sistema.'),
    ('PUT', '/usuarios/{id}', 'JSON: {nom_usr, dir_usr, ...}', '200 OK: Datos actualizados del usuario en MySQL.'),
]

for row_idx, data in enumerate(filas_end):
    row = t_end.add_row()
    bg = HEX_GRIS_CLARO if row_idx % 2 == 1 else 'FFFFFF'
    for c_idx, val in enumerate(data):
        cell = row.cells[c_idx]
        set_cell_background(cell, bg)
        set_cell_margins(cell, top=80, bottom=80, left=80, right=80)
        p = cell.paragraphs[0]
        r = p.add_run(val)
        r.font.name = 'Arial'
        r.font.size = Pt(8.5)
        if c_idx == 0:
            r.font.bold = True
            r.font.color.rgb = COLOR_VINO if val == 'POST' else (COLOR_DORADO if val == 'GET' else RGBColor(0, 100, 200))

add_body_p('Comprobación de la Creación y Lectura de Comentarios: Al acceder a PostDetailPage en Flutter, la vista ejecuta ComentarioService().obtenerComentariosPorBlog(post.id). El endpoint en FastAPI ejecuta un JOIN entre comentarios y usuario para entregar el nombre de quien redactó el comentario. Cuando el usuario escribe en el campo inferior y presiona Enviar, se dispara POST /comentarios con validación de llaves foráneas y recarga reactiva inmediata.', italic=True)

# 7. Reflexión
add_custom_heading('7. Reflexión sobre el Proceso de Desarrollo', 1)
add_body_p('El desarrollo de esta práctica representó una consolidación significativa de conocimientos en el ciclo de vida del software multiplataforma. Como equipo conformado por Aaron Alexander Paniagua Chávez y David Hernández González, enfrentamos retos sustanciales de arquitectura:')
add_body_p('1. En primer término, la compatibilidad en el transporte de recursos multimedia: inicialmente existía discrepancia entre la recepción de archivos multipart y el envío de cadenas base64 por parte de los servicios móviles. Se diseñó un endpoint en FastAPI que inspecciona la cabecera Content-Type para decodificar automáticamente flujos base64 y guardarlos como archivos físicos en /uploads, preservando el almacenamiento óptimo en MySQL.')
add_body_p('2. En segundo término, la normalización estricta de tipos de datos en la base de datos relacional para el campo tip_usu (manejado como entero 1 y 2), asegurando que el validador Pydantic normalice cualquier representación previa de roles sin alterar la integridad de MySQL.')
add_body_p('3. Finalmente, la adopción de Google Chrome como entorno de despliegue y pruebas de Flutter eliminó las fricciones tradicionales asociadas a los emuladores de Android pesados, permitiendo pruebas instantáneas y validaciones de interfaz en tiempo real.')

# 8. Repositorio y Cuentas de Acceso
add_custom_heading('8. Información del Repositorio y Credenciales de Evaluación', 1)
add_body_p('El código fuente completo, el script SQL de creación y los diagramas se encuentran publicados en el repositorio oficial:')
add_body_p('Liga al Repositorio Público: https://github.com/dvdhgon/app_movil (Validado accesible en modo incógnito)', bold_prefix='Repositorio: ')
add_body_p('Cuentas Semilla Preconfiguradas para Pruebas del Video y Calificación:\n• Administrador: admin@duncan.com / Contraseña: Admin123* (Rol 1 - Acceso Total)\n• Autor (Aaron): aaron@duncan.com / Contraseña: Aaron123* (Rol 2 - Blog y Comentarios)\n• Autor (David): david@duncan.com / Contraseña: David123* (Rol 2 - Blog y Comentarios)\n• Docente UTEQ: adriana@uteq.edu.mx / Contraseña: Uteq2026* (Rol 1 - Evaluadora)', bold_prefix='Credenciales: ')

output_path = r'C:\Users\Aarón\Desktop\Aprendizaje en programacion\02_Proyectos\repo_github\reportes\Reporte_Tecnico_Evaluacion_Unidad_3.docx'
doc.save(output_path)
print('Documento Word generado exitosamente en:', output_path)
