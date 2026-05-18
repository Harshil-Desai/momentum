# Build stage
FROM golang:1.24-alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

# Build the main server binary
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o momentum .

# Build the migrate CLI binary
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o migrate ./cmd/migrate/

# Runtime stage
FROM alpine:3.21

RUN apk --no-cache add ca-certificates tzdata

WORKDIR /app

COPY --from=builder /app/momentum .
COPY --from=builder /app/migrate .
COPY --from=builder /app/migrations ./migrations/
COPY docker-entrypoint.sh .
RUN chmod +x momentum migrate docker-entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["./docker-entrypoint.sh"]
