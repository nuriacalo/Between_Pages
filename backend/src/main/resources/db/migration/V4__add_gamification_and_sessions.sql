-- V4: Cambiar el tipo de la columna series_order a DOUBLE PRECISION
ALTER TABLE book_journal ALTER COLUMN series_order TYPE DOUBLE PRECISION;

-- Eliminamos PENDING (dejamos TBR) y eliminamos BOUGHT (ya usas ownership)
ALTER TABLE book_journal DROP CONSTRAINT IF EXISTS book_journal_status_check;
ALTER TABLE book_journal ADD CONSTRAINT book_journal_status_check
   CHECK (status IN ('WISHLIST', 'TBR', 'READING', 'PAUSED', 'DROPPED', 'FINISHED'));

ALTER TABLE manga_journal DROP CONSTRAINT IF EXISTS manga_journal_status_check;
ALTER TABLE manga_journal ADD CONSTRAINT manga_journal_status_check
   CHECK (status IN ('WISHLIST', 'TBR', 'READING', 'PAUSED', 'DROPPED', 'FINISHED'));

ALTER TABLE fanfic_journal DROP CONSTRAINT IF EXISTS fanfic_journal_status_check;
ALTER TABLE fanfic_journal ADD CONSTRAINT fanfic_journal_status_check
   CHECK (status IN ('WISHLIST', 'TBR', 'READING', 'PAUSED', 'DROPPED', 'FINISHED'));


-- Agregar tablas para gamificación y sesiones de lectura

-- Tabla para las sesiones de lectura temporizadas
CREATE TABLE IF NOT EXISTS reading_session (
   id SERIAL PRIMARY KEY,
   user_id INT NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
   item_type VARCHAR(20) NOT NULL CHECK (item_type IN ('BOOK', 'MANGA', 'FANFIC')),
   item_id INT NOT NULL,
   duration_seconds INT NOT NULL,
   pages_read INT NOT NULL,
   session_date TIMESTAMP DEFAULT NOW()
);

-- Tabla para la actividad diaria de lectura (gamificación)
CREATE TABLE IF NOT EXISTS reading_activity (
   id SERIAL PRIMARY KEY,
   user_id INT NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
   activity_date DATE NOT NULL DEFAULT CURRENT_DATE,
   UNIQUE(user_id, activity_date)
);

-- Tabla para las metas anuales de lectura (gamificación)
CREATE TABLE IF NOT EXISTS reading_goal (
   id SERIAL PRIMARY KEY,
   user_id INT NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
   goal_year INT NOT NULL,
   target_amount INT NOT NULL,
   UNIQUE(user_id, goal_year)
);
