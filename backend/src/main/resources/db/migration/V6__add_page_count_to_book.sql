ALTER TABLE book ADD COLUMN IF NOT EXISTS page_count INT;
-- En lugar de item_type y item_id, haz esto:
CREATE TABLE IF NOT EXISTS reading_session (
                                               id BIGSERIAL PRIMARY KEY,
                                               user_id BIGINT NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,

    -- Claves foráneas reales
    book_id BIGINT REFERENCES book(id) ON DELETE CASCADE,
    manga_id BIGINT REFERENCES manga(id) ON DELETE CASCADE,
    fanfic_id BIGINT REFERENCES fanfiction(id) ON DELETE CASCADE,

    duration_seconds INT NOT NULL,
    pages_read INT NOT NULL,
    session_date TIMESTAMP DEFAULT NOW(),

    -- Restricción: Solo debe haber un tipo de obra referenciada
    CHECK (
(book_id IS NOT NULL AND manga_id IS NULL AND fanfic_id IS NULL) OR
(book_id IS NULL AND manga_id IS NOT NULL AND fanfic_id IS NULL) OR
(book_id IS NULL AND manga_id IS NULL AND fanfic_id IS NOT NULL)
    )
    );