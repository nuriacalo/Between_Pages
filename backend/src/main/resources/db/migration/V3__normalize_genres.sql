-- 1. Crear la tabla maestra de géneros
CREATE TABLE genre (
    id   SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL
);

-- 2. Crear las tablas relacionales de unión
CREATE TABLE book_genre (
    book_id  BIGINT NOT NULL REFERENCES book(id) ON DELETE CASCADE,
    genre_id INT    NOT NULL REFERENCES genre(id) ON DELETE CASCADE,
    PRIMARY KEY (book_id, genre_id)
);

CREATE TABLE manga_genre (
    manga_id BIGINT NOT NULL REFERENCES manga(id) ON DELETE CASCADE,
    genre_id INT    NOT NULL REFERENCES genre(id) ON DELETE CASCADE,
    PRIMARY KEY (manga_id, genre_id)
);

CREATE TABLE fanfiction_genre (
    fanfic_id BIGINT NOT NULL REFERENCES fanfiction(id) ON DELETE CASCADE,
    genre_id  INT    NOT NULL REFERENCES genre(id) ON DELETE CASCADE,
    PRIMARY KEY (fanfic_id, genre_id)
);