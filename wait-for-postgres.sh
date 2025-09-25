#!/bin/sh
set -e

host="$1"
shift
cmd="$@"

echo "Waiting for Postgres at $host..."
until pg_isready -h "$host" -p 5432; do
  echo "Postgres is unavailable - sleeping"
  sleep 2
done

echo "Postgres is up - executing command"
exec $cmd
