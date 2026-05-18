-- name: CreateUser :one
INSERT INTO users (email, password_hash, push_token)
VALUES ($1, $2, $3)
RETURNING *;

-- name: GetUserByID :one
SELECT * FROM users WHERE id = $1;

-- name: GetUserByEmail :one
SELECT * FROM users WHERE email = $1;

-- name: UpdateUser :one
UPDATE users SET email = $1, password_hash = $2, push_token = $3, updated_at = NOW()
WHERE id = $4
RETURNING *;

-- name: UpdateUserPushToken :exec
UPDATE users SET push_token = $1, updated_at = NOW() WHERE id = $2;

-- name: DeleteUser :exec
DELETE FROM users WHERE id = $1;

-- name: UserExistsByEmail :one
SELECT EXISTS(SELECT 1 FROM users WHERE email = $1);
