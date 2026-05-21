CREATE TABLE achievements (
    id          TEXT PRIMARY KEY,
    name        TEXT NOT NULL,
    description TEXT NOT NULL,
    icon        TEXT NOT NULL,
    criteria    JSONB NOT NULL DEFAULT '{}',
    sort_order  INT  NOT NULL DEFAULT 0
);

CREATE TABLE user_achievements (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id        UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    achievement_id TEXT NOT NULL REFERENCES achievements(id),
    earned_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (user_id, achievement_id)
);

CREATE TABLE user_achievement_progress (
    user_id        UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    achievement_id TEXT NOT NULL REFERENCES achievements(id),
    current_value  INT  NOT NULL DEFAULT 0,
    target_value   INT  NOT NULL,
    metadata       JSONB NOT NULL DEFAULT '{}',
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, achievement_id)
);

CREATE INDEX idx_user_achievements_user ON user_achievements(user_id);
CREATE INDEX idx_user_achievement_progress_user ON user_achievement_progress(user_id);
