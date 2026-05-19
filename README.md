# Cadence

Find Your Rhythm. A habit-tracking app that helps you gently integrate positive habits into your daily life until they become an effortless, consistent beat.

**Backend:** Go 1.24 · Gin · PostgreSQL 17  
**Mobile:** Flutter/Dart 3.8+ · Riverpod · go_router

---

## Features

- **Habit CRUD** — create, edit, archive, and restore habits with custom icons, colors, and frequency schedules
- **Daily check-in** — idempotent check-ins with streak tracking and miss-recovery UX
- **Habit detail** — full history, current streak, your *why*, and a two-minute version for low-energy days
- **Insights** — aggregate stats: monthly completion rate, day-of-week patterns, best streaks, total check-ins
- **Weekly reflection** — locally journaled reflections tied to the week's data
- **Archive eulogy** — retiring a habit surfaces how many times you showed up ("You showed up 47 times. That counts.")
- **Secure auth** — JWT-based login/register; token stored in device secure storage

---

## Architecture

```
┌─────────────────────────────────────────────┐
│                 Flutter App                 │
│  go_router → screens → Riverpod providers   │
│         Dio (JWT interceptor)               │
└───────────────────┬─────────────────────────┘
                    │ HTTPS / JSON
┌───────────────────▼─────────────────────────┐
│              Go REST API (Gin)              │
│  routes → middleware → controllers          │
│         → services → repositories          │
└───────────────────┬─────────────────────────┘
                    │ pgx/v5 pool
┌───────────────────▼─────────────────────────┐
│            PostgreSQL 17                    │
│  users · habits · checkins                  │
│  get_habit_streak() · get_habit_best_streak()│
└─────────────────────────────────────────────┘
```

### Backend layer responsibilities

| Layer | Location | Responsibility |
|---|---|---|
| Config | `config/` | Viper — reads `.env`, exposes typed config struct |
| DB | `db/` | pgxpool connection, `WithTransaction` helper, migration runner |
| Migrations | `migrations/` | Versioned `.up.sql` / `.down.sql` pairs; auto-run on server start |
| Models | `models/` | Structs for User, Habit, Checkin; request/response DTOs |
| Repositories | `repositories/` | Raw SQL — one file per entity |
| Services | `services/` | Business logic; sits between controllers and repositories |
| Controllers | `controllers/` | Gin handlers — bind JSON → call service → return JSON |
| Routes | `routes/router.go` | All routes registered in one place; API group prefixed `/api` |
| Middleware | `middleware/` | CORS (permissive dev config), JWT auth |

---

## Prerequisites

| Tool | Version | Notes |
|---|---|---|
| Go | 1.24+ | [golang.org/dl](https://golang.org/dl/) |
| Docker + Docker Compose | any recent | For the local Postgres instance |
| Flutter | 3.8+ | [flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install) |
| Dart | 3.8+ | Bundled with Flutter |
| Android SDK | API 23+ | `minSdkVersion 23` required by `flutter_secure_storage` |

---

## Getting Started

### 1. Clone

```sh
git clone https://github.com/your-org/momentum.git
cd momentum
```

### 2. Backend

```sh
cd backend

# Copy and edit environment variables
cp .env.example .env

# Start PostgreSQL + the Go server together
docker-compose up
```

Migrations run automatically when the server starts. The API is available at `http://localhost:8080`.

To run the server without Docker (requires a running Postgres instance):

```sh
go run main.go
```

### 3. Mobile

```sh
cd mobile

# Install dependencies
flutter pub get

# Regenerate Riverpod code (required after any provider changes)
dart run build_runner build --delete-conflicting-outputs

# Run on a connected device or emulator
flutter run
```

> **Android note:** Your emulator or physical device must be on API level 23 or higher.

---

## Environment Variables

Create `backend/.env` from the template below. Never commit real secrets.

| Variable | Default | Description |
|---|---|---|
| `PORT` | `8080` | Port the API server listens on |
| `ENVIRONMENT` | `development` | `development` or `production` |
| `DATABASE_URL` | *(see below)* | Full PostgreSQL connection string |
| `DB_MAX_OPEN_CONNS` | `25` | pgxpool max open connections |
| `DB_MAX_IDLE_CONNS` | `25` | pgxpool max idle connections |
| `DB_CONN_MAX_LIFETIME` | `5m` | Connection max lifetime |
| `JWT_SECRET` | `changeme-replace-in-production` | **Change this in production** |

```env
PORT=8080
ENVIRONMENT=development
DATABASE_URL=postgres://postgres:password@localhost:5432/momentum?sslmode=disable
DB_MAX_OPEN_CONNS=25
DB_MAX_IDLE_CONNS=25
DB_CONN_MAX_LIFETIME=5m
JWT_SECRET=changeme-replace-in-production
```

> Docker Compose maps PostgreSQL to **host port 5433** (not 5432) to avoid conflicts with any local Postgres instance.

---

## API Reference

Base URL: `http://localhost:8080/api`

### Authentication

| Method | Path | Auth | Description |
|---|---|---|---|
| `POST` | `/auth/register` | — | Create account; returns JWT |
| `POST` | `/auth/login` | — | Log in; returns JWT |

All other endpoints require `Authorization: Bearer <token>`.

**Register / Login request body:**
```json
{
  "email": "you@example.com",
  "password": "yourpassword"
}
```

**Response:**
```json
{
  "token": "<jwt>"
}
```

---

### Habits

| Method | Path | Description |
|---|---|---|
| `GET` | `/habits` | List active habits |
| `POST` | `/habits` | Create a habit |
| `PUT` | `/habits/:id` | Update a habit |
| `DELETE` | `/habits/:id` | Archive a habit |
| `GET` | `/habits/archived` | List archived habits |

**Create / Update habit body:**
```json
{
  "name": "Morning run",
  "icon": "🏃",
  "color": "#FF6B6B",
  "note": "Why this matters to me",
  "two_minute_version": "Put on shoes and step outside",
  "frequency": { "type": "daily" }
}
```

`frequency` is a JSONB field. `type` accepts `"daily"` for now; `days` accepts an array of weekday integers for weekly habits.

---

### Check-ins & Streaks

| Method | Path | Description |
|---|---|---|
| `POST` | `/habits/:id/checkins` | Log a check-in (idempotent) |
| `GET` | `/habits/:id/history` | Check-in dates, lifetime count, `checked_today`, `missed_yesterday` |
| `GET` | `/habits/:id/streak` | Current streak count |

**Check-in body:**
```json
{ "date": "2026-05-17" }
```

Date format is `YYYY-MM-DD`. Posting the same date twice is safe — it returns 200 and does nothing.

---

### Insights

| Method | Path | Description |
|---|---|---|
| `GET` | `/insights` | Aggregate stats across all habits |

Response includes: total check-ins, monthly completion rate, day-of-week breakdown, current and best streaks per habit, strongest day of the week.

---

### Health

| Method | Path | Auth | Description |
|---|---|---|---|
| `GET` | `/health` | Bearer JWT | Liveness + DB connection check |

---

## Database Migrations

The migration runner lives in `cmd/migrate/` and tracks applied versions in a `migrations` table. Migrations run **automatically on server start** — you only need these commands for manual intervention.

```sh
# From backend/
go run cmd/migrate/main.go status   # see what's applied
go run cmd/migrate/main.go up       # apply all pending migrations
go run cmd/migrate/main.go down     # roll back the last migration
go run cmd/migrate/main.go version  # print current version
```

**Never edit existing migration files.** Add new `.up.sql` / `.down.sql` pairs with the next version number.

---

## Development Workflow

### Backend

```sh
# Run all tests
go test ./...

# Run a single package
go test ./services/...

# Build binary
go build -o momentum .

# Rebuild Docker image and restart
docker-compose up --build
```

### Mobile

```sh
# Lint — zero warnings required before committing
flutter analyze

# Run tests
flutter test

# Regenerate Riverpod providers after any @riverpod annotation change
dart run build_runner build --delete-conflicting-outputs

# Build release APK
flutter build apk
```

### Dev Seed Account

Migration 005 seeds a development user so you can make authenticated API calls on a fresh clone without registering:

| Field | Value |
|---|---|
| Email | `harshil.desai@gasleaksensors.com` |
| Password | `momentum123` |

---

## Project Structure

```
momentum/
├── backend/
│   ├── main.go
│   ├── config/             # Viper config loader
│   ├── db/                 # pgxpool setup, WithTransaction, migration runner
│   ├── migrations/         # *.up.sql / *.down.sql (007 migrations)
│   ├── models/             # Domain structs + request/response DTOs
│   ├── repositories/       # Raw SQL — user, habit, checkin, insights
│   ├── services/           # Business logic — auth, habit, checkin, insights
│   ├── controllers/        # Gin handlers — auth, habit, checkin, insights
│   ├── routes/             # router.go — all routes in one place
│   ├── middleware/         # CORS, JWT auth middleware
│   ├── cmd/migrate/        # Standalone migration CLI binary
│   ├── Dockerfile
│   └── docker-compose.yml
└── mobile/
    ├── lib/
    │   ├── main.dart
    │   ├── core/
    │   │   ├── api_client.dart   # Dio instance + JWT interceptor
    │   │   └── router.dart       # go_router configuration
    │   └── features/
    │       ├── auth/             # Login, register screens + AuthProvider
    │       ├── habits/           # List, detail, create, edit + providers
    │       ├── insights/         # Insights screen + InsightsProvider
    │       ├── reflection/       # Weekly reflection + local journal
    │       └── settings/         # Archived habits shelf, sign out
    └── pubspec.yaml
```

---

## Contributing

1. **Branch** from `main` — use `feature/`, `fix/`, or `chore/` prefixes.
2. **Backend:** `go test ./...` must pass; `go vet ./...` must be clean.
3. **Mobile:** `flutter analyze` must report zero warnings.
4. **Migrations:** add new versioned pairs; never edit existing files.
5. **Secrets:** never commit `.env` or real credentials — `.env.example` only.
6. Open a pull request with a clear description of *what* changed and *why*.

---

## License

MIT — see [LICENSE](LICENSE).
