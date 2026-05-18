-- Create function to get user's streak for a habit
CREATE OR REPLACE FUNCTION get_habit_streak(p_user_id UUID, p_habit_id UUID)
RETURNS INTEGER AS $$
DECLARE
    current_streak INTEGER := 0;
    check_date DATE := CURRENT_DATE;
BEGIN
    -- Check consecutive days from today backwards
    WHILE EXISTS (
        SELECT 1 FROM checkins
        WHERE user_id = p_user_id
        AND habit_id = p_habit_id
        AND date = check_date
    ) LOOP
        current_streak := current_streak + 1;
        check_date := check_date - INTERVAL '1 day';
    END LOOP;
    
    RETURN current_streak;
END;
$$ LANGUAGE plpgsql;

-- Create function to get user's monthly checkin count
CREATE OR REPLACE FUNCTION get_monthly_checkins(p_user_id UUID, p_habit_id UUID, p_month DATE)
RETURNS INTEGER AS $$
DECLARE
    checkin_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO checkin_count
    FROM checkins
    WHERE user_id = p_user_id 
    AND habit_id = p_habit_id
    AND date >= DATE_TRUNC('month', p_month)
    AND date < DATE_TRUNC('month', p_month) + INTERVAL '1 month';
    
    RETURN checkin_count;
END;
$$ LANGUAGE plpgsql;