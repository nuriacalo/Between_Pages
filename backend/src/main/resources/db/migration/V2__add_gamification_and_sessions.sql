-- Tabla para las sesiones de lectura temporizadas (Estructura corregida final)
CREATE TABLE reading_session (
   id               BIGSERIAL PRIMARY KEY,
   user_id          BIGINT    NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
   book_id          BIGINT    REFERENCES book(id) ON DELETE CASCADE,
   manga_id         BIGINT    REFERENCES manga(id) ON DELETE CASCADE,
   fanfic_id        BIGINT    REFERENCES fanfiction(id) ON DELETE CASCADE,
   duration_seconds INT       NOT NULL,
   pages_read       INT       NOT NULL,
   session_date     TIMESTAMP DEFAULT NOW(),
   CHECK (
      (book_id IS NOT NULL AND manga_id IS NULL AND fanfic_id IS NULL) OR
      (book_id IS NULL AND manga_id IS NOT NULL AND fanfic_id IS NULL) OR
      (book_id IS NULL AND manga_id IS NULL AND fanfic_id IS NOT NULL)
   )
);

-- Tabla para la actividad diaria de lectura (gamificación con BIGINT para Java)
CREATE TABLE reading_activity (
   id            BIGSERIAL PRIMARY KEY,
   user_id       BIGINT NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
   activity_date DATE   NOT NULL DEFAULT CURRENT_DATE,
   UNIQUE(user_id, activity_date)
);

-- Tabla para las metas anuales de lectura
CREATE TABLE reading_goal (
   id            BIGSERIAL PRIMARY KEY,
   user_id       BIGINT NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
   goal_year     INT    NOT NULL,
   target_amount INT    NOT NULL,
   UNIQUE(user_id, goal_year)
);

-- Módulo de anotaciones de lectura
CREATE TABLE notes (
    id         BIGSERIAL PRIMARY KEY,
    user_id    BIGINT       NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    book_id    VARCHAR(255) NOT NULL,
    quote      TEXT,
    note       TEXT,
    page       INT,
    created_at TIMESTAMP    NOT NULL DEFAULT NOW()
);