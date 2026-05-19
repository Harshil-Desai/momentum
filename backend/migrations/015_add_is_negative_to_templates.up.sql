ALTER TABLE habit_templates ADD COLUMN is_negative BOOLEAN NOT NULL DEFAULT false;

UPDATE habit_templates SET is_negative = true WHERE name IN (
  'No alcohol today',
  'No screens 1h before bed'
);
