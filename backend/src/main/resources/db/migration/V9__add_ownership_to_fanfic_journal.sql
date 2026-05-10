ALTER TABLE fanfic_journal ADD COLUMN ownership VARCHAR(20) CHECK (ownership IN ('DIGITAL', 'PHYSICAL', 'NONE', 'BORROWED'));
ALTER TABLE fanfic_journal ADD COLUMN loaned_to VARCHAR(100);
ALTER TABLE fanfic_journal ADD COLUMN reading_format VARCHAR(50) CHECK (reading_format IN ('PHYSICAL', 'DIGITAL', 'AUDIOBOOK'));