-- V7: Normalizar la gestión de géneros

-- 1. Crear la tabla maestra de géneros
CREATE TABLE IF NOT EXISTS genre (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL
);

-- 2. Crear las tablas de unión para la relación muchos a muchos

-- Tabla de unión para libros y géneros
CREATE TABLE IF NOT EXISTS book_genre (
    book_id BIGINT NOT NULL REFERENCES book(id) ON DELETE CASCADE,
    genre_id INT NOT NULL REFERENCES genre(id) ON DELETE CASCADE,
    PRIMARY KEY (book_id, genre_id)
);

-- Tabla de unión para mangas y géneros
CREATE TABLE IF NOT EXISTS manga_genre (
    manga_id BIGINT NOT NULL REFERENCES manga(id) ON DELETE CASCADE,
    genre_id INT NOT NULL REFERENCES genre(id) ON DELETE CASCADE,
    PRIMARY KEY (manga_id, genre_id)
);

-- Tabla de unión para fanfictions y géneros
CREATE TABLE IF NOT EXISTS fanfiction_genre (
    fanfic_id BIGINT NOT NULL REFERENCES fanfiction(id) ON DELETE CASCADE,
    genre_id INT NOT NULL REFERENCES genre(id) ON DELETE CASCADE,
    PRIMARY KEY (fanfic_id, genre_id)
);

-- 3. Eliminar las antiguas columnas de género de las tablas de catálogo
-- Se elimina después de haber migrado los datos (si los hubiera).
-- En nuestro caso, como la base de datos está casi vacía, podemos eliminarlas directamente.
ALTER TABLE book DROP COLUMN IF EXISTS genre;
ALTER TABLE manga DROP COLUMN IF EXISTS genre;
ALTER TABLE fanfiction DROP COLUMN IF EXISTS genre;
