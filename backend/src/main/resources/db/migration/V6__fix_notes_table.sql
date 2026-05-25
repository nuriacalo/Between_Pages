DROP TABLE IF EXISTS notes;

CREATE TABLE notes (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    item_type VARCHAR(20) NOT NULL,
    item_id BIGINT NOT NULL,
    quote TEXT,
    note TEXT,
    page INT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);