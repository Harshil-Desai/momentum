-- Drop checkins table and related objects
DROP TRIGGER IF EXISTS prevent_future_checkins_trigger ON checkins;
DROP FUNCTION IF EXISTS prevent_future_checkins();
DROP TABLE IF EXISTS checkins;