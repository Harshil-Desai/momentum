package repositories

import (
	"context"
	"momentum/db"
	"momentum/models"
	"time"

	"github.com/jackc/pgx/v5"
)

type UserRepository struct{}

func NewUserRepository() *UserRepository {
	return &UserRepository{}
}

func (r *UserRepository) Create(user *models.User) error {
	query := `
		INSERT INTO users (email, password_hash, push_token)
		VALUES ($1, $2, $3)
		RETURNING id, created_at, updated_at
	`
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	return db.Pool.QueryRow(ctx, query,
		user.Email, user.PasswordHash, user.PushToken,
	).Scan(&user.ID, &user.CreatedAt, &user.UpdatedAt)
}

func (r *UserRepository) FindByID(id string) (*models.User, error) {
	query := `
		SELECT id, email, password_hash, push_token, created_at, updated_at
		FROM users WHERE id = $1
	`
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	var user models.User
	err := db.Pool.QueryRow(ctx, query, id).Scan(
		&user.ID, &user.Email, &user.PasswordHash, &user.PushToken,
		&user.CreatedAt, &user.UpdatedAt,
	)
	if err == pgx.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return &user, nil
}

func (r *UserRepository) FindByEmail(email string) (*models.User, error) {
	query := `
		SELECT id, email, password_hash, push_token, created_at, updated_at
		FROM users WHERE email = $1
	`
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	var user models.User
	err := db.Pool.QueryRow(ctx, query, email).Scan(
		&user.ID, &user.Email, &user.PasswordHash, &user.PushToken,
		&user.CreatedAt, &user.UpdatedAt,
	)
	if err == pgx.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return &user, nil
}

func (r *UserRepository) Update(user *models.User) error {
	query := `
		UPDATE users
		SET email = $1, password_hash = $2, push_token = $3, updated_at = NOW()
		WHERE id = $4
		RETURNING updated_at
	`
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	return db.Pool.QueryRow(ctx, query,
		user.Email, user.PasswordHash, user.PushToken, user.ID,
	).Scan(&user.UpdatedAt)
}

func (r *UserRepository) UpdatePushToken(userID string, pushToken *string) error {
	query := `UPDATE users SET push_token = $1, updated_at = NOW() WHERE id = $2`
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	_, err := db.Pool.Exec(ctx, query, pushToken, userID)
	return err
}

func (r *UserRepository) Delete(id string) error {
	query := `DELETE FROM users WHERE id = $1`
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	_, err := db.Pool.Exec(ctx, query, id)
	return err
}

func (r *UserRepository) ExistsByEmail(email string) (bool, error) {
	query := `SELECT EXISTS(SELECT 1 FROM users WHERE email = $1)`
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	var exists bool
	err := db.Pool.QueryRow(ctx, query, email).Scan(&exists)
	return exists, err
}
