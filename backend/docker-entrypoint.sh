#!/bin/sh
set -e

echo "Running database migrations..."
./migrate up

echo "Migrations complete. Starting server..."
exec ./cadence
