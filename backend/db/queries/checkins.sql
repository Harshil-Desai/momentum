-- name: CreateCheckin :one
INSERT INTO checkins (user_id, habit_id, date)
VALUES ($1, $2, $3)
ON CONFLICT (user_id, habit_id, date) DO NOTHING
RETURNING *;

-- name: GetCheckinByDate :one
SELECT * FROM checkins WHERE user_id = $1 AND habit_id = $2 AND date = $3;

-- name: ListCheckinsByHabit :many
SELECT * FROM checkins WHERE user_id = $1 AND habit_id = $2 ORDER BY date DESC;

-- name: GetCurrentStreak :one
SELECT get_habit_streak($1::uuid, $2::uuid) AS streak;

-- name: GetMonthlyCheckins :one
SELECT get_monthly_checkins($1::uuid, $2::uuid, $3::date) AS count;
