-- Drop utility functions
DROP FUNCTION IF EXISTS get_habit_streak(UUID, UUID);
DROP FUNCTION IF EXISTS get_monthly_checkins(UUID, UUID, DATE);