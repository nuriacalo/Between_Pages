-- Características de Sagas y Préstamos para Libros y Mangas
ALTER TABLE book_journal  ADD COLUMN series_name VARCHAR(255);
ALTER TABLE book_journal  ADD COLUMN series_order DOUBLE PRECISION;
ALTER TABLE book_journal  ADD COLUMN loaned_to VARCHAR(100);

ALTER TABLE manga_journal ADD COLUMN loaned_to VARCHAR(100);

-- Características de Préstamos y Formatos adaptados al Diario de Fanfictions
ALTER TABLE fanfic_journal ADD COLUMN ownership VARCHAR(20) CHECK (ownership IN ('DIGITAL', 'PHYSICAL', 'NONE', 'BORROWED'));
ALTER TABLE fanfic_journal ADD COLUMN reading_format VARCHAR(50) CHECK (reading_format IN ('PHYSICAL', 'DIGITAL', 'AUDIOBOOK'));
ALTER TABLE fanfic_journal ADD COLUMN loaned_to VARCHAR(100);