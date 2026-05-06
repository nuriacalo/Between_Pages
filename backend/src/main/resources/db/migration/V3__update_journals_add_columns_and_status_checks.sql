

-- =========================
-- USERS & ACTIVITY
-- =========================
CREATE TABLE app_user (
                          id SERIAL PRIMARY KEY,
                          name VARCHAR(100) NOT NULL,
                          email VARCHAR(150) UNIQUE NOT NULL,
                          password_hash VARCHAR(255) NOT NULL,
                          role VARCHAR(20) NOT NULL DEFAULT 'USER'
                              CHECK (role IN ('USER', 'ADMIN')),
                          created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Tabla para la racha semanal y días activos
CREATE TABLE reading_activity (
                                  id SERIAL PRIMARY KEY,
                                  user_id INT NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
                                  activity_date DATE NOT NULL DEFAULT CURRENT_DATE,
                                  UNIQUE(user_id, activity_date)
);

-- Tabla para la meta anual de lectura
CREATE TABLE reading_goal (
                              id SERIAL PRIMARY KEY,
                              user_id INT NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
                              goal_year INT NOT NULL,
                              target_amount INT NOT NULL,
                              UNIQUE(user_id, goal_year)
);

-- =========================
-- MEDIA CATALOG (Catálogo de Obras)
-- =========================
CREATE TABLE book (
                      id SERIAL PRIMARY KEY,
                      google_books_id VARCHAR(50) UNIQUE,
                      title VARCHAR(255) NOT NULL,
                      author VARCHAR(255) NOT NULL,
                      isbn VARCHAR(20),
                      publisher VARCHAR(150),
                      description TEXT,
                      cover_url VARCHAR(255),
                      genre VARCHAR(100),
                      book_type VARCHAR(50)
                          CHECK (book_type IN ('STANDALONE','DUOLOGY','TRILOGY','SAGA','SERIES')),
                      publication_year INT
);

-- Tabla optimizada para los datos de la API Jikan (MyAnimeList v4)
CREATE TABLE manga (
                       id SERIAL PRIMARY KEY,
                       mal_id INT UNIQUE,
                       source VARCHAR(50) DEFAULT 'MyAnimeList',
                       title VARCHAR(255) NOT NULL,
                       author VARCHAR(255) NOT NULL,
                       demographic VARCHAR(100),
                       genre VARCHAR(255),
                       description TEXT,
                       cover_url VARCHAR(255),
                       total_chapters INT,
                       total_volumes INT,
                       mal_score DECIMAL(4,2),
                       publication_status VARCHAR(50)
                           CHECK (publication_status IN ('Publishing', 'Finished', 'On Hiatus', 'Discontinued', 'Not yet published'))
);

CREATE TABLE fanfiction (
                            id SERIAL PRIMARY KEY,
                            ao3_id VARCHAR(50) UNIQUE,
                            title VARCHAR(255) NOT NULL,
                            author VARCHAR(255) NOT NULL,
                            source_material VARCHAR(255),
                            description TEXT,
                            cover_url VARCHAR(255),
                            genre VARCHAR(100),
                            main_ship VARCHAR(150),
                            theme VARCHAR(150),
                            current_chapter INT DEFAULT 0,
                            total_chapters INT,
                            publication_status VARCHAR(50)
                                CHECK (publication_status IN ('ONGOING','COMPLETED','ABANDONED'))
);

CREATE TABLE fanfic_tag (
                            id SERIAL PRIMARY KEY,
                            fanfic_id INT NOT NULL REFERENCES fanfiction(id) ON DELETE CASCADE,
                            tag VARCHAR(100) NOT NULL
);

-- =========================
-- JOURNALS (Diarios del Usuario)
-- =========================
CREATE TABLE book_journal (
                              id SERIAL PRIMARY KEY,
                              user_id INT NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
                              book_id INT NOT NULL REFERENCES book(id) ON DELETE CASCADE,
                              status VARCHAR(50) NOT NULL
                                  CHECK (status IN ('PENDING', 'READING', 'FINISHED', 'DROPPED', 'PAUSED', 'TBR')),
                              current_page INT DEFAULT 0,
                              rating INT CHECK (rating BETWEEN 1 AND 10),
                              tear_drops INT CHECK (tear_drops BETWEEN 0 AND 5),
                              spice_flames INT CHECK (spice_flames BETWEEN 0 AND 5),
                              reading_format VARCHAR(50)
                                  CHECK (reading_format IN ('PHYSICAL','DIGITAL','AUDIOBOOK')),
                              emotions JSONB,
                              favorite_quotes TEXT,
                              personal_notes TEXT,
                              start_date DATE,
                              end_date DATE,
                              updated_at TIMESTAMP DEFAULT NOW(),
                              rereading BOOLEAN DEFAULT FALSE,
                              ownership VARCHAR(20)
                                  CHECK (ownership IN ('DIGITAL', 'PHYSICAL', 'NONE', 'BORROWED'))
);

CREATE TABLE manga_journal (
                               id SERIAL PRIMARY KEY,
                               user_id INT NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
                               manga_id INT NOT NULL REFERENCES manga(id) ON DELETE CASCADE,
                               status VARCHAR(50) NOT NULL
                                   CHECK (status IN ('PENDING', 'READING', 'FINISHED', 'DROPPED', 'PAUSED', 'TBR')),
                               current_chapter INT DEFAULT 0,
                               current_volume INT DEFAULT 0,
                               rating INT CHECK (rating BETWEEN 1 AND 10),
                               tear_drops INT CHECK (tear_drops BETWEEN 0 AND 5),
                               spice_flames INT CHECK (spice_flames BETWEEN 0 AND 5),
                               reading_format VARCHAR(50)
                                   CHECK (reading_format IN ('PHYSICAL','DIGITAL')),
                               favorite_character VARCHAR(150),
                               favorite_arc VARCHAR(150),
                               personal_notes TEXT,
                               start_date DATE,
                               end_date DATE,
                               updated_at TIMESTAMP DEFAULT NOW(),
                               rereading BOOLEAN DEFAULT FALSE,
                               ownership VARCHAR(20)
                                   CHECK (ownership IN ('DIGITAL', 'PHYSICAL', 'NONE', 'BORROWED'))
);

CREATE TABLE fanfic_journal (
                                id SERIAL PRIMARY KEY,
                                user_id INT NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
                                fanfic_id INT NOT NULL REFERENCES fanfiction(id) ON DELETE CASCADE,
                                status VARCHAR(50) NOT NULL
                                    CHECK (status IN ('PENDING','READING','FINISHED','DROPPED')),
                                current_chapter INT DEFAULT 0,
                                rating INT CHECK (rating BETWEEN 1 AND 10),
                                tear_drops INT CHECK (tear_drops BETWEEN 0 AND 5),
                                spice_flames INT CHECK (spice_flames BETWEEN 0 AND 5),
                                main_ship VARCHAR(150),
                                secondary_ships VARCHAR(255),
                                theme VARCHAR(150),
                                angst_level VARCHAR(50)
                                    CHECK (angst_level IN ('NONE','LOW','MEDIUM','HIGH','EXTREME')),
                                ship_loyalty VARCHAR(50),
                                canon_type VARCHAR(50)
                                    CHECK (canon_type IN ('CANON','AU','CANON_DIVERGENT')),
                                rereading BOOLEAN DEFAULT FALSE,
                                personal_notes TEXT,
                                start_date DATE,
                                end_date DATE,
                                updated_at TIMESTAMP DEFAULT NOW()
);

-- =========================
-- LISTS (Listas Personalizadas)
-- =========================
CREATE TABLE list (
                      id SERIAL PRIMARY KEY,
                      user_id INT NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
                      name VARCHAR(150) NOT NULL,
                      description TEXT
);

CREATE TABLE list_item (
                           id SERIAL PRIMARY KEY,
                           list_id INT NOT NULL REFERENCES list(id) ON DELETE CASCADE,
                           item_type VARCHAR(20) NOT NULL
                               CHECK (item_type IN ('BOOK','MANGA','FANFIC')),
                           book_id INT REFERENCES book(id) ON DELETE CASCADE,
                           manga_id INT REFERENCES manga(id) ON DELETE CASCADE,
                           fanfic_id INT REFERENCES fanfiction(id) ON DELETE CASCADE,
                           position INT,

    -- Restricción polimórfica: solo un tipo de ID puede estar lleno a la vez
                           CHECK (
                               (book_id IS NOT NULL AND manga_id IS NULL AND fanfic_id IS NULL) OR
                               (book_id IS NULL AND manga_id IS NOT NULL AND fanfic_id IS NULL) OR
                               (book_id IS NULL AND manga_id IS NULL AND fanfic_id IS NOT NULL)
                               )
);



-- 1. Añadir columnas del Módulo 2 que faltan en la BBDD
ALTER TABLE book_journal ADD COLUMN series_name VARCHAR(255);
ALTER TABLE book_journal ADD COLUMN series_order DECIMAL(6,2);
ALTER TABLE book_journal ADD COLUMN loaned_to VARCHAR(255);

ALTER TABLE manga_journal ADD COLUMN loaned_to VARCHAR(255);

-- 2. Actualizar las restricciones (CHECK) de los estados para permitir WISHLIST y BOUGHT
ALTER TABLE book_journal DROP CONSTRAINT IF EXISTS book_journal_status_check;
ALTER TABLE book_journal ADD CONSTRAINT book_journal_status_check
    CHECK (status IN ('PENDING', 'READING', 'FINISHED', 'DROPPED', 'PAUSED', 'TBR', 'WISHLIST', 'BOUGHT'));

ALTER TABLE manga_journal DROP CONSTRAINT IF EXISTS manga_journal_status_check;
ALTER TABLE manga_journal ADD CONSTRAINT manga_journal_status_check
    CHECK (status IN ('PENDING', 'READING', 'FINISHED', 'DROPPED', 'PAUSED', 'TBR', 'WISHLIST', 'BOUGHT'));

ALTER TABLE fanfic_journal DROP CONSTRAINT IF EXISTS fanfic_journal_status_check;
ALTER TABLE fanfic_journal ADD CONSTRAINT fanfic_journal_status_check
    CHECK (status IN ('PENDING', 'READING', 'FINISHED', 'DROPPED', 'PAUSED', 'TBR', 'WISHLIST', 'BOUGHT'));



-- V3: Añadir columnas de módulo 2 y actualizar CHECKs para estados

-- 1. Añadir columnas del Módulo 2 que faltan en la BBDD
ALTER TABLE book_journal ADD COLUMN IF NOT EXISTS series_name VARCHAR(255);
ALTER TABLE book_journal ADD COLUMN IF NOT EXISTS series_order DECIMAL(6,2);
ALTER TABLE book_journal ADD COLUMN IF NOT EXISTS loaned_to VARCHAR(255);

ALTER TABLE manga_journal ADD COLUMN IF NOT EXISTS loaned_to VARCHAR(255);

-- 2. Actualizar las restricciones (CHECK) de los estados para permitir WISHLIST y BOUGHT
ALTER TABLE book_journal DROP CONSTRAINT IF EXISTS book_journal_status_check;
ALTER TABLE book_journal ADD CONSTRAINT book_journal_status_check
    CHECK (status IN ('PENDING', 'READING', 'FINISHED', 'DROPPED', 'PAUSED', 'TBR', 'WISHLIST', 'BOUGHT'));

ALTER TABLE manga_journal DROP CONSTRAINT IF EXISTS manga_journal_status_check;
ALTER TABLE manga_journal ADD CONSTRAINT manga_journal_status_check
    CHECK (status IN ('PENDING', 'READING', 'FINISHED', 'DROPPED', 'PAUSED', 'TBR', 'WISHLIST', 'BOUGHT'));

ALTER TABLE fanfic_journal DROP CONSTRAINT IF EXISTS fanfic_journal_status_check;
ALTER TABLE fanfic_journal ADD CONSTRAINT fanfic_journal_status_check
    CHECK (status IN ('PENDING', 'READING', 'FINISHED', 'DROPPED', 'PAUSED', 'TBR', 'WISHLIST', 'BOUGHT'));

-- Nota: esta migración asume que las tablas existen. Ejecuta Flyway/`mvn spring-boot:run` para aplicar en tu entorno local.


-- V4: Cambiar el tipo de la columna series_order a DOUBLE PRECISION

ALTER TABLE book_journal
ALTER COLUMN series_order TYPE DOUBLE PRECISION;



