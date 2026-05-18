CREATE TABLE grace_days (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    habit_id   UUID NOT NULL REFERENCES habits(id) ON DELETE CASCADE,
    date       DATE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (user_id, habit_id, date)
);

-- Rewrite get_habit_streak to treat grace days as non-breaking
CREATE OR REPLACE FUNCTION get_habit_streak(p_user_id UUID, p_habit_id UUID)
RETURNS INTEGER AS $$
DECLARE
    current_streak INTEGER := 0;
    check_date DATE := CURRENT_DATE;
BEGIN
    LOOP
        IF EXISTS (
            SELECT 1 FROM checkins
            WHERE user_id = p_user_id AND habit_id = p_habit_id AND date = check_date
        ) OR EXISTS (
            SELECT 1 FROM grace_days
            WHERE user_id = p_user_id AND habit_id = p_habit_id AND date = check_date
        ) THEN
            current_streak := current_streak + 1;
            check_date := check_date - INTERVAL '1 day';
        ELSE
            EXIT;
        END IF;
    END LOOP;
    RETURN current_streak;
END;
$$ LANGUAGE plpgsql;
