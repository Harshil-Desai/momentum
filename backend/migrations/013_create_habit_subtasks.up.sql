CREATE TABLE habit_subtasks (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    habit_id   UUID NOT NULL REFERENCES habits(id) ON DELETE CASCADE,
    label      TEXT NOT NULL,
    sort_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE checkins ADD COLUMN completed_subtask_ids UUID[] NOT NULL DEFAULT '{}';
