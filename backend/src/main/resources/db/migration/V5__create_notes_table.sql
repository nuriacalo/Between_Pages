CREATE TABLE notes (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    book_id VARCHAR(255) NOT NULL,
    quote TEXT,
    note TEXT,
    page INT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);