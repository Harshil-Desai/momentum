CREATE OR REPLACE FUNCTION get_habit_best_streak(p_user_id UUID, p_habit_id UUID)
RETURNS INTEGER AS $$
DECLARE
  best        INTEGER := 0;
  current_run INTEGER := 0;
  prev_date   DATE    := NULL;
  check_date  DATE;
BEGIN
  FOR check_date IN
    SELECT date::date
    FROM checkins
    WHERE user_id = p_user_id AND habit_id = p_habit_id
    ORDER BY date ASC
  LOOP
    IF prev_date IS NULL OR check_date = prev_date + INTERVAL '1 day' THEN
      current_run := current_run + 1;
    ELSE
      current_run := 1;
    END IF;
    IF current_run > best THEN
      best := current_run;
    END IF;
    prev_date := check_date;
  END LOOP;
  RETURN best;
END;
$$ LANGUAGE plpgsql;
