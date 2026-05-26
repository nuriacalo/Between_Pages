-- =================================================================
-- 7. TABLA DE CATÁLOGO POR USUARIO
-- =================================================================
CREATE TABLE user_catalog (
    id          BIGSERIAL PRIMARY KEY,
    user_id     BIGINT NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    item_type   VARCHAR(20) NOT NULL CHECK (item_type IN ('BOOK', 'MANGA', 'FANFIC')),
    book_id     BIGINT REFERENCES book(id) ON DELETE CASCADE,
    manga_id    BIGINT REFERENCES manga(id) ON DELETE CASCADE,
    fanfic_id   BIGINT REFERENCES fanfiction(id) ON DELETE CASCADE,
    added_at    TIMESTAMP NOT NULL DEFAULT NOW(),

    -- Restricción para asegurar que solo uno de los IDs de item está presente
    CHECK (
        (item_type = 'BOOK' AND book_id IS NOT NULL AND manga_id IS NULL AND fanfic_id IS NULL) OR
        (item_type = 'MANGA' AND book_id IS NULL AND manga_id IS NOT NULL AND fanfic_id IS NULL) OR
        (item_type = 'FANFIC' AND book_id IS NULL AND manga_id IS NULL AND fanfic_id IS NOT NULL)
    ),

    -- Restricción para evitar duplicados por usuario e item
    UNIQUE (user_id, item_type, book_id),
    UNIQUE (user_id, item_type, manga_id),
    UNIQUE (user_id, item_type, fanfic_id)
);

-- Índices para mejorar el rendimiento de las consultas
CREATE INDEX idx_user_catalog_user_id ON user_catalog(user_id);
CREATE INDEX idx_user_catalog_item_type ON user_catalog(item_type);
