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
