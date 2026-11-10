-- ============================================================
-- FocusHabit · Base de datos SQLite
-- Seguimiento de hábitos saludables durante el estudio
-- ============================================================

PRAGMA foreign_keys = ON;

-- ------------------------------------------------------------
-- 1. ESQUEMA
-- ------------------------------------------------------------

DROP TABLE IF EXISTS alerta;
DROP TABLE IF EXISTS registro;
DROP TABLE IF EXISTS habito;
DROP TABLE IF EXISTS categoria;

CREATE TABLE categoria (
    id      INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre  TEXT    NOT NULL UNIQUE,
    color   TEXT    NOT NULL DEFAULT '#4CAF50'
            CHECK (color GLOB '#[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]')
);

CREATE TABLE habito (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    categoria_id INTEGER NOT NULL,
    nombre       TEXT    NOT NULL,
    meta_diaria  INTEGER NOT NULL DEFAULT 1 CHECK (meta_diaria > 0),
    FOREIGN KEY (categoria_id) REFERENCES categoria(id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE registro (
    id        INTEGER PRIMARY KEY AUTOINCREMENT,
    habito_id INTEGER NOT NULL,
    fecha     TEXT    NOT NULL                       -- formato 'YYYY-MM-DD'
              CHECK (fecha GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'),
    cantidad  INTEGER NOT NULL DEFAULT 1 CHECK (cantidad > 0),
    FOREIGN KEY (habito_id) REFERENCES habito(id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE alerta (
    id     INTEGER PRIMARY KEY AUTOINCREMENT,
    fecha  TEXT NOT NULL                              -- 'YYYY-MM-DD HH:MM:SS'
           DEFAULT (datetime('now', 'localtime')),
    tipo   TEXT NOT NULL
           CHECK (tipo IN ('postura', 'descanso_visual'))
);

-- Índices para las consultas más frecuentes
CREATE INDEX idx_habito_categoria   ON habito(categoria_id);
CREATE INDEX idx_registro_habito_fecha ON registro(habito_id, fecha);
CREATE INDEX idx_alerta_fecha       ON alerta(fecha);


-- ------------------------------------------------------------
-- 2. DATOS INICIALES (categorías y hábitos de partida)
-- ------------------------------------------------------------

INSERT INTO categoria (nombre, color) VALUES
    ('Ergonomía',    '#FF9800'),
    ('Salud visual', '#9C27B0'),
    ('Hidratación',  '#2196F3'),
    ('Enfoque',      '#3F51B5'),
    ('Ejercicio',    '#4CAF50'),
    ('Sueño',        '#607D8B');

INSERT INTO habito (categoria_id, nombre, meta_diaria) VALUES
    ((SELECT id FROM categoria WHERE nombre = 'Ergonomía'),    'Postura recta en la silla',                4),
    ((SELECT id FROM categoria WHERE nombre = 'Salud visual'), 'Regla 20-20-20 (descanso visual)',         6),
    ((SELECT id FROM categoria WHERE nombre = 'Hidratación'),  'Vaso de agua al despertar',                1),
    ((SELECT id FROM categoria WHERE nombre = 'Ergonomía'),    'Pausa activa y estiramientos',             3),
    ((SELECT id FROM categoria WHERE nombre = 'Enfoque'),      'Bloque de enfoque profundo (Pomodoro)',    4),
    ((SELECT id FROM categoria WHERE nombre = 'Salud visual'), 'Parpadeo consciente e hidratación ocular', 5),
    ((SELECT id FROM categoria WHERE nombre = 'Ejercicio'),    'Caminar o subir escaleras',                2),
    ((SELECT id FROM categoria WHERE nombre = 'Hidratación'),  'Beber agua durante la jornada',            8),
    ((SELECT id FROM categoria WHERE nombre = 'Sueño'),        'Desconectar pantallas antes de dormir',    1),
    ((SELECT id FROM categoria WHERE nombre = 'Ergonomía'),    'Ajustar brillo y distancia del monitor',   1);
