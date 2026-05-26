-- =================================================================
-- 8. AÑADIR ESTADO AL CATÁLOGO DE USUARIO
-- =================================================================

-- Añade la columna 'status' a la tabla 'user_catalog' para rastrear el estado
-- de cada item (TBR, READING, FINISHED, etc.) directamente en el catálogo personal.
-- Esto crea una "fuente única de verdad" para el estado de un item en la biblioteca.

ALTER TABLE user_catalog
ADD COLUMN status VARCHAR(50) NOT NULL DEFAULT 'TBR'
CHECK (status IN ('WISHLIST', 'TBR', 'READING', 'PAUSED', 'DROPPED', 'FINISHED'));

-- Opcional: Añadir un índice sobre la nueva columna de estado para optimizar
-- las consultas que filtren por estado en el futuro.
CREATE INDEX idx_user_catalog_status ON user_catalog(status);
