-- Create checkins table
CREATE TABLE checkins (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    habit_id UUID NOT NULL REFERENCES habits(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create unique constraint for one checkin per habit per day per user
CREATE UNIQUE INDEX unique_checkin_per_day 
ON checkins (user_id, habit_id, date);

-- Create additional indexes for performance
CREATE INDEX idx_checkins_user_id ON checkins(user_id);
CREATE INDEX idx_checkins_habit_id ON checkins(habit_id);
CREATE INDEX idx_checkins_date ON checkins(date);
CREATE INDEX idx_checkins_user_date ON checkins(user_id, date);
CREATE INDEX idx_checkins_habit_date ON checkins(habit_id, date);
CREATE INDEX idx_checkins_user_habit_date ON checkins(user_id, habit_id, date DESC);

-- Create a function to prevent future-dated checkins
CREATE OR REPLACE FUNCTION prevent_future_checkins()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.date > CURRENT_DATE THEN
        RAISE EXCEPTION 'Checkin date cannot be in the future';
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to prevent future checkins
CREATE TRIGGER prevent_future_checkins_trigger
    BEFORE INSERT OR UPDATE ON checkins
    FOR EACH ROW
    EXECUTE FUNCTION prevent_future_checkins();