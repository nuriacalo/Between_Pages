-- ==========================================
-- 1. USUARIOS Y ESQUEMA BASE
-- ==========================================
CREATE TABLE app_user (
   id            BIGSERIAL PRIMARY KEY,
   name          VARCHAR(100)  NOT NULL,
   email         VARCHAR(150)  UNIQUE NOT NULL,
   password_hash VARCHAR(255)  NOT NULL,
   role          VARCHAR(20)   NOT NULL DEFAULT 'USER' CHECK (role IN ('USER', 'ADMIN')),
   created_at    TIMESTAMP     NOT NULL DEFAULT NOW()
);

-- ==========================================
-- 2. CATÁLOGOS DE MEDIOS (OBRAS)
-- ==========================================
CREATE TABLE book (
   id               BIGSERIAL PRIMARY KEY,
   google_books_id  VARCHAR(50)  UNIQUE,
   title            VARCHAR(255) NOT NULL,
   author           VARCHAR(255) NOT NULL,
   isbn             VARCHAR(20),
   publisher        VARCHAR(150),
   description      TEXT,
   cover_url        VARCHAR(255),
   page_count       INT,
   book_type        VARCHAR(50)  CHECK (book_type IN ('STANDALONE','DUOLOGY','TRILOGY','SAGA','SERIES')),
   publication_year INT
);

CREATE TABLE manga (
   id                 BIGSERIAL PRIMARY KEY,
   mal_id             INT          UNIQUE,
   source             VARCHAR(50)  DEFAULT 'MyAnimeList',
   title              VARCHAR(255) NOT NULL,
   author             VARCHAR(255) NOT NULL,
   demographic        VARCHAR(100),
   description        TEXT,
   cover_url          VARCHAR(255),
   total_chapters     INT,
   total_volumes      INT,
   mal_score          DECIMAL(4,2),
   publication_status VARCHAR(50)  CHECK (publication_status IN ('Publishing', 'Finished', 'On Hiatus', 'Discontinued', 'Not yet published'))
);

CREATE TABLE fanfiction (
   id                 BIGSERIAL PRIMARY KEY,
   ao3_id             VARCHAR(50)  UNIQUE,
   title              VARCHAR(255) NOT NULL,
   author             VARCHAR(255) NOT NULL,
   source_material    VARCHAR(255),
   description        TEXT,
   cover_url          VARCHAR(255),
   main_ship          VARCHAR(150),
   theme              VARCHAR(150),
   current_chapter    INT          DEFAULT 0,
   total_chapters     INT,
   publication_status VARCHAR(50)  CHECK (publication_status IN ('ONGOING','COMPLETED','ABANDONED'))
);

CREATE TABLE fanfic_tag (
   id        BIGSERIAL PRIMARY KEY,
   fanfic_id BIGINT       NOT NULL REFERENCES fanfiction(id) ON DELETE CASCADE,
   tag       VARCHAR(100) NOT NULL
);

-- ==========================================
-- 3. DIARIOS DEL USUARIO (JOURNALS)
-- ==========================================
CREATE TABLE book_journal (
   id              BIGSERIAL PRIMARY KEY,
   user_id         BIGINT       NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
   book_id         BIGINT       NOT NULL REFERENCES book(id) ON DELETE CASCADE,
   status          VARCHAR(50)  NOT NULL CHECK (status IN ('WISHLIST', 'TBR', 'READING', 'PAUSED', 'DROPPED', 'FINISHED')),
   current_page    INT          DEFAULT 0,
   rating          INT          CHECK (rating BETWEEN 1 AND 10),
   tear_drops      INT          CHECK (tear_drops BETWEEN 0 AND 5),
   spice_flames    INT          CHECK (spice_flames BETWEEN 0 AND 5),
   reading_format  VARCHAR(50)  CHECK (reading_format IN ('PHYSICAL','DIGITAL','AUDIOBOOK')),
   emotions        JSONB,
   favorite_quotes TEXT,
   personal_notes  TEXT,
   start_date      DATE,
   end_date        DATE,
   updated_at      TIMESTAMP    DEFAULT NOW(),
   rereading       BOOLEAN      DEFAULT FALSE,
   ownership       VARCHAR(20)  CHECK (ownership IN ('DIGITAL', 'PHYSICAL', 'NONE', 'BORROWED'))
);

CREATE TABLE manga_journal (
   id                 BIGSERIAL PRIMARY KEY,
   user_id            BIGINT       NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
   manga_id           BIGINT       NOT NULL REFERENCES manga(id) ON DELETE CASCADE,
   status             VARCHAR(50)  NOT NULL CHECK (status IN ('WISHLIST', 'TBR', 'READING', 'PAUSED', 'DROPPED', 'FINISHED')),
   current_chapter    INT          DEFAULT 0,
   current_volume     INT          DEFAULT 0,
   rating             INT          CHECK (rating BETWEEN 1 AND 10),
   tear_drops         INT          CHECK (tear_drops BETWEEN 0 AND 5),
   spice_flames       INT          CHECK (spice_flames BETWEEN 0 AND 5),
   reading_format     VARCHAR(50)  CHECK (reading_format IN ('PHYSICAL','DIGITAL')),
   favorite_character VARCHAR(150),
   favorite_arc       VARCHAR(150),
   personal_notes     TEXT,
   start_date         DATE,
   end_date           DATE,
   updated_at         TIMESTAMP    DEFAULT NOW(),
   rereading          BOOLEAN      DEFAULT FALSE,
   ownership          VARCHAR(20)  CHECK (ownership IN ('DIGITAL', 'PHYSICAL', 'NONE', 'BORROWED'))
);

CREATE TABLE fanfic_journal (
   id              BIGSERIAL PRIMARY KEY,
   user_id         BIGINT       NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
   fanfic_id       BIGINT       NOT NULL REFERENCES fanfiction(id) ON DELETE CASCADE,
   status          VARCHAR(50)  NOT NULL CHECK (status IN ('WISHLIST', 'TBR', 'READING', 'PAUSED', 'DROPPED', 'FINISHED')),
   current_chapter INT          DEFAULT 0,
   rating          INT          CHECK (rating BETWEEN 1 AND 10),
   tear_drops      INT          CHECK (tear_drops BETWEEN 0 AND 5),
   spice_flames    INT          CHECK (spice_flames BETWEEN 0 AND 5),
   main_ship       VARCHAR(150),
   secondary_ships VARCHAR(255),
   theme           VARCHAR(150),
   angst_level     VARCHAR(50)  CHECK (angst_level IN ('NONE','LOW','MEDIUM','HIGH','EXTREME')),
   ship_loyalty    VARCHAR(50),
   canon_type      VARCHAR(50)  CHECK (canon_type IN ('CANON','AU','CANON_DIVERGENT')),
   rereading       BOOLEAN      DEFAULT FALSE,
   personal_notes  TEXT,
   start_date      DATE,
   end_date        DATE,
   updated_at      TIMESTAMP    DEFAULT NOW()
);

-- ==========================================
-- 4. LISTAS PERSONALIZADAS
-- ==========================================
CREATE TABLE list (
   id          BIGSERIAL PRIMARY KEY,
   user_id     BIGINT       NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
   name        VARCHAR(150) NOT NULL,
   description TEXT
);

CREATE TABLE list_item (
   id        BIGSERIAL PRIMARY KEY,
   list_id   BIGINT      NOT NULL REFERENCES list(id) ON DELETE CASCADE,
   item_type VARCHAR(20) NOT NULL CHECK (item_type IN ('BOOK','MANGA','FANFIC')),
   book_id   BIGINT      REFERENCES book(id) ON DELETE CASCADE,
   manga_id  BIGINT      REFERENCES manga(id) ON DELETE CASCADE,
   fanfic_id BIGINT      REFERENCES fanfiction(id) ON DELETE CASCADE,
   position  INT,
   CHECK (
      (book_id IS NOT NULL AND manga_id IS NULL AND fanfic_id IS NULL) OR
      (book_id IS NULL AND manga_id IS NOT NULL AND fanfic_id IS NULL) OR
      (book_id IS NULL AND manga_id IS NULL AND fanfic_id IS NOT NULL)
   )
);