-- V5: Arreglar tipos de columnas para que coincidan con Long (BIGINT) en Java
ALTER TABLE reading_session ALTER COLUMN id TYPE BIGINT;
ALTER TABLE reading_session ALTER COLUMN user_id TYPE BIGINT;
ALTER TABLE reading_session ALTER COLUMN item_id TYPE BIGINT;

ALTER TABLE reading_activity ALTER COLUMN id TYPE BIGINT;
ALTER TABLE reading_activity ALTER COLUMN user_id TYPE BIGINT;

ALTER TABLE reading_goal ALTER COLUMN id TYPE BIGINT;
ALTER TABLE reading_goal ALTER COLUMN user_id TYPE BIGINT;
