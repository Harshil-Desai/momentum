CREATE TABLE milestones (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    habit_id   UUID NOT NULL REFERENCES habits(id) ON DELETE CASCADE,
    milestone_value INT NOT NULL,
    achieved_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (user_id, habit_id, milestone_value)
);
