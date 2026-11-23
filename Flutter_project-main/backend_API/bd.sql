-- ==============================================================================
-- PROYECTO: DUNCAN MASCOTAS - EVALUACIÓN UNIDAD 3
-- MATERIA: APLICACIONES MÓVILES / WEB MULTIPLATAFORMA
-- UNIVERSIDAD TECNOLÓGICA DE QUERÉTARO (UTEQ)
-- AUTORES: Aaron Alexander Paniagua Chávez, David Hernández González
-- SCRIPT DE CREACIÓN DE BASE DE DATOS Y POBLADO DE DATOS (MYSQL)
-- ==============================================================================

CREATE DATABASE IF NOT EXISTS bd_aplicacion_movil
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE bd_aplicacion_movil;

-- 1. TABLA: USUARIO
CREATE TABLE IF NOT EXISTS usuario (
    id_usr INT AUTO_INCREMENT PRIMARY KEY,
    nom_usr VARCHAR(100) NOT NULL,
    mail VARCHAR(150) NOT NULL UNIQUE,
    pass VARCHAR(255) NOT NULL,
    dir_usr VARCHAR(200) NULL,
    tip_usu INT NOT NULL DEFAULT 2, -- 1 = Administrador, 2 = Usuario / Autor
    foto_perfil VARCHAR(500) NULL
);

-- 2. TABLA: BLOG
CREATE TABLE IF NOT EXISTS blog (
    id_blog INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(150) NOT NULL,
    `desc` TEXT NULL,
    img VARCHAR(500) NULL,
    tags VARCHAR(255) NULL
);

-- 3. TABLA: COMENTARIOS
CREATE TABLE IF NOT EXISTS comentarios (
    id_com INT AUTO_INCREMENT PRIMARY KEY,
    comentario TEXT NOT NULL,
    fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estatus INT NOT NULL DEFAULT 1,
    usr_id INT NOT NULL,
    blog_id INT NOT NULL,

    CONSTRAINT fk_comentario_usuario
        FOREIGN KEY (usr_id)
        REFERENCES usuario(id_usr)
        ON DELETE CASCADE,

    CONSTRAINT fk_comentario_blog
        FOREIGN KEY (blog_id)
        REFERENCES blog(id_blog)
        ON DELETE CASCADE
);

-- ==============================================================================
-- INSERCIÓN DE DATOS SEMILLA (USUARIOS DE PRUEBA CON CONTRASEÑAS ENCRIPTADAS BCrypt)
-- Contraseñas en texto plano para pruebas y video:
-- admin@duncan.com     -> Admin123*   (Rol 1: Administrador General)
-- aaron@duncan.com     -> Aaron123*   (Rol 2: Autor / Estudiante Aaron)
-- david@duncan.com     -> David123*   (Rol 2: Autor / Estudiante David)
-- adriana@uteq.edu.mx  -> Uteq2026*   (Rol 1: Docente / Evaluadora)
-- ==============================================================================

INSERT INTO usuario (id_usr, nom_usr, mail, pass, dir_usr, tip_usu, foto_perfil)
VALUES
    (1, 'Administrador General', 'admin@duncan.com', '$2b$12$3kfPms2W583IxkktdfZIJeKXqF7cdZDD7ikWM/h2qoprRF465h.lS', 'Santiago de Querétaro, Qro.', 1, NULL),
    (2, 'Aaron Alexander Paniagua Chávez', 'aaron@duncan.com', '$2b$12$E0DdWhbtXP9A2Mg/CavLkOqeqURfb0TQuZni6vu4nAcxMSyOEiW.C', 'Corregidora, Querétaro', 2, NULL),
    (3, 'David Hernández González', 'david@duncan.com', '$2b$12$T.Vdpl1qtQ0MX.ITz9r2WO1SvErM7CfvXbMK4wM.yDdJb3aI2NsqC', 'El Marqués, Querétaro', 2, NULL),
    (4, 'Adriana Y Contreras Alvarez', 'adriana@uteq.edu.mx', '$2b$12$JTm/Qxv21DFiFUewO99kveeeiqa0jYYbF4fGgvqmLejSjqCUnP3aq', 'Campus UTEQ Querétaro', 1, NULL)
ON DUPLICATE KEY UPDATE
    nom_usr = VALUES(nom_usr),
    pass = VALUES(pass),
    dir_usr = VALUES(dir_usr),
    tip_usu = VALUES(tip_usu);

-- ==============================================================================
-- INSERCIÓN DE PUBLICACIONES DEL BLOG (DUNCAN MASCOTAS)
-- ==============================================================================

INSERT INTO blog (id_blog, titulo, `desc`, img, tags)
VALUES
    (
        1,
        'Guía esencial para el cuidado de cachorros',
        'El periodo de adaptación de un cachorro en su nuevo hogar requiere paciencia, estimulación temprana y una rutina equilibrada de paseos y descanso para asegurar su desarrollo físico y emocional.',
        'https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&w=800&q=80',
        'Cachorros, Bienestar, Cuidados'
    ),
    (
        2,
        'Beneficios del ejercicio diario en perros adultos',
        'Caminar un mínimo de 30 a 45 minutos al día previene problemas de sobrepeso, reduce el estrés y la ansiedad por separación, fortaleciendo además el vínculo afectivo con su cuidador.',
        'https://images.unsplash.com/photo-1534361960057-19889db98a1e?auto=format&fit=crop&w=800&q=80',
        'Paseos, Salud Canina, Rutinas'
    ),
    (
        3,
        'Nutrición y alimentación balanceada',
        'Conocer la proporción adecuada de proteínas, grasas y micronutrientes según la edad, tamaño y nivel de actividad física de tu mascota previene enfermedades gastrointestinales crónicas.',
        'https://images.unsplash.com/photo-1589924691995-400dc9ecc119?auto=format&fit=crop&w=800&q=80',
        'Nutrición, Mascotas, Salud'
    ),
    (
        4,
        'Socialización canina en parques urbanos',
        'Consejos prácticos para interactuar en áreas pet-friendly de Querétaro como la Alameda Hidalgo y el Parque Carretas, manteniendo siempre control con correa y respeto a otros perros.',
        'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?auto=format&fit=crop&w=800&q=80',
        'Socialización, Parques, Querétaro'
    )
ON DUPLICATE KEY UPDATE
    titulo = VALUES(titulo),
    `desc` = VALUES(`desc`),
    img = VALUES(img),
    tags = VALUES(tags);

-- ==============================================================================
-- INSERCIÓN DE COMENTARIOS INICIALES
-- ==============================================================================

INSERT INTO comentarios (id_com, comentario, estatus, usr_id, blog_id)
VALUES
    (1, 'Excelente artículo, muy útil la información sobre la estimulación temprana de los cachorros.', 1, 2, 1),
    (2, 'Totalmente de acuerdo, el paseo diario cambió por completo la energía de mi perro.', 1, 3, 2),
    (3, 'Muy buen enfoque nutricional. Se nota la investigación técnica del equipo.', 1, 4, 3),
    (4, 'Recomiendo ampliamente los parques de Querétaro mencionados en la publicación.', 1, 1, 4)
ON DUPLICATE KEY UPDATE
    comentario = VALUES(comentario);
