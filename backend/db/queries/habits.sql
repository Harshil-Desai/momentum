-- name: CreateHabit :one
INSERT INTO habits (user_id, name, icon, color, frequency, two_minute_version, stack_after_habit_id)
VALUES ($1, $2, $3, $4, $5, $6, $7)
RETURNING *;

-- name: GetHabitByID :one
SELECT * FROM habits WHERE id = $1 AND archived = false;

-- name: ListHabitsByUser :many
SELECT * FROM habits WHERE user_id = $1 AND archived = false ORDER BY created_at ASC;

-- name: UpdateHabit :one
UPDATE habits SET name = $1, icon = $2, color = $3, frequency = $4, two_minute_version = $5, stack_after_habit_id = $6, updated_at = NOW()
WHERE id = $7 AND user_id = $8
RETURNING *;

-- name: ArchiveHabit :exec
UPDATE habits SET archived = true, updated_at = NOW() WHERE id = $1 AND user_id = $2;
