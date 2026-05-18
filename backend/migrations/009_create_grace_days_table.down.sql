DROP TABLE IF EXISTS grace_days;

-- Restore original streak function (without grace days)
CREATE OR REPLACE FUNCTION get_habit_streak(p_user_id UUID, p_habit_id UUID)
RETURNS INTEGER AS $$
DECLARE
    current_streak INTEGER := 0;
    check_date DATE := CURRENT_DATE;
BEGIN
    WHILE EXISTS (
        SELECT 1 FROM checkins
        WHERE user_id = p_user_id AND habit_id = p_habit_id AND date = check_date
    ) LOOP
        current_streak := current_streak + 1;
        check_date := check_date - INTERVAL '1 day';
    END LOOP;
    RETURN current_streak;
END;
$$ LANGUAGE plpgsql;
