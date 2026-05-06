-- V4: Cambiar el tipo de la columna series_order a DOUBLE PRECISION

ALTER TABLE book_journal
ALTER COLUMN series_order TYPE DOUBLE PRECISION;
