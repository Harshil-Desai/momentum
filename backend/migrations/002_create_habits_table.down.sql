-- Drop habits table and related objects
DROP TRIGGER IF EXISTS update_habits_updated_at ON habits;
DROP TABLE IF EXISTS habits;