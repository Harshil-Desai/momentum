-- Create habits table
CREATE TABLE habits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    icon VARCHAR(100),
    color VARCHAR(50),
    frequency JSONB NOT NULL DEFAULT '{}',
    two_minute_version TEXT,
    stack_after_habit_id UUID REFERENCES habits(id) ON DELETE SET NULL,
    archived BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for habits table
CREATE INDEX idx_habits_user_id ON habits(user_id);
CREATE INDEX idx_habits_stack_after_habit_id ON habits(stack_after_habit_id);
CREATE INDEX idx_habits_archived ON habits(archived);
CREATE INDEX idx_habits_created_at ON habits(created_at);
CREATE INDEX idx_habits_user_archived ON habits(user_id, archived);

-- Create GIN index for JSONB frequency field for better query performance
CREATE INDEX idx_habits_frequency ON habits USING GIN (frequency);

-- Add trigger for updated_at
CREATE TRIGGER update_habits_updated_at
    BEFORE UPDATE ON habits
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();