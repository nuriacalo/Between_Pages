ALTER TABLE app_user
ADD COLUMN current_streak INT NOT NULL DEFAULT 0,
ADD COLUMN last_reading_date DATE;
