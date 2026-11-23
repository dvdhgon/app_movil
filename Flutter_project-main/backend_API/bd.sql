-- ==============================================================================
-- PROYECTO: DUNCAN MASCOTAS - BASE DE DATOS UNIFICADA (WEB + MÓVIL)
-- Reinicia sistema_duncan dejando únicamente tus 2 usuarios configurados
-- ==============================================================================

DROP DATABASE IF EXISTS sistema_duncan;

CREATE DATABASE sistema_duncan
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE sistema_duncan;

-- ==============================================================================
-- 1. TABLA COMPARTIDA: USUARIO (Web y App Móvil)
-- ==============================================================================
CREATE TABLE usuario (
    id_usr INT AUTO_INCREMENT PRIMARY KEY,
    nom_usr VARCHAR(100) NOT NULL,
    mail VARCHAR(150) NOT NULL UNIQUE,
    pass VARCHAR(255) NOT NULL,
    dir_usr VARCHAR(200) NULL,
    tip_usu INT NOT NULL DEFAULT 1, -- En tu Web: 2 = Administrador, 1 = Usuario normal
    foto_perfil VARCHAR(500) NULL
);

-- ==============================================================================
-- 2. TABLAS EXCLUSIVAS DE LA APP MÓVIL
-- ==============================================================================
CREATE TABLE blog (
    id_blog INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(150) NOT NULL,
    `desc` TEXT NULL,
    img VARCHAR(500) NULL,
    tags VARCHAR(255) NULL
);

CREATE TABLE comentarios (
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
-- 3. TABLAS EXCLUSIVAS DE LA PÁGINA WEB (Duncan Mascotas)
-- ==============================================================================
CREATE TABLE web_publicaciones (
    id_publicacion INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    contenido TEXT NOT NULL,
    imagen VARCHAR(255) NULL,
    etiquetas VARCHAR(255) NULL,
    estado ENUM('borrador', 'publicada') DEFAULT 'publicada',
    fecha_publicacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    id_autor INT NOT NULL,

    CONSTRAINT fk_web_pub_autor
        FOREIGN KEY (id_autor)
        REFERENCES usuario(id_usr)
        ON DELETE CASCADE
);

CREATE TABLE web_comentarios (
    id_comentario INT AUTO_INCREMENT PRIMARY KEY,
    comentario TEXT NOT NULL,
    fecha_comentario DATETIME DEFAULT CURRENT_TIMESTAMP,
    id_usuario INT NOT NULL,
    id_publicacion INT NOT NULL,

    CONSTRAINT fk_web_com_usu
        FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usr)
        ON DELETE CASCADE,

    CONSTRAINT fk_web_com_pub
        FOREIGN KEY (id_publicacion)
        REFERENCES web_publicaciones(id_publicacion)
        ON DELETE CASCADE
);

-- ==============================================================================
-- 4. TUS ÚNICOS USUARIOS INICIALES
-- ==============================================================================
INSERT INTO usuario (id_usr, nom_usr, mail, pass, dir_usr, tip_usu, foto_perfil)
VALUES
    (1, 'Administrador', 'admin@gmail.com', '12345678', 'Querétaro', 2, NULL),
    (2, 'Usuario Normal', 'miachoche@gmail.com', '12345678', 'Querétaro', 1, NULL);

-- ==============================================================================
-- 5. PUBLICACIONES Y COMENTARIOS INICIALES (APP MÓVIL)
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
    );

INSERT INTO comentarios (id_com, comentario, estatus, usr_id, blog_id)
VALUES
    (1, 'Excelente artículo, muy útil la información sobre la estimulación temprana de los cachorros.', 1, 2, 1),
    (2, 'Totalmente de acuerdo, el paseo diario cambió por completo la energía de mi perro.', 1, 2, 2),
    (3, 'Muy buen enfoque nutricional. Se nota la investigación técnica del equipo.', 1, 1, 3),
    (4, 'Recomiendo ampliamente los parques de Querétaro mencionados en la publicación.', 1, 1, 4);

-- ==============================================================================
-- 6. PUBLICACIONES INICIALES (PÁGINA WEB)
-- ==============================================================================
INSERT INTO web_publicaciones (id_publicacion, titulo, contenido, imagen, etiquetas, estado, id_autor)
VALUES
    (
        1,
        'Cuidados Básicos para un Cachorro',
        'Llevar un nuevo cachorro a casa requiere paciencia, alimentación balanceada y revisiones veterinarias constantes...',
        'logo duncan.jpeg',
        'salud,cachorros,cuidados',
        'publicada',
        1
    ),
    (
        2,
        'Importancia del Paseo Diario Canino',
        'El ejercicio físico y la estimulación mental durante los paseos diarios reducen sensiblemente los niveles de estrés...',
        '',
        'paseo,bienestar,ejercicio',
        'publicada',
        1
    );