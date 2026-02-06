#!/usr/bin/env bash
set -euo pipefail

# Remove a potentially pre-existing server pid for puma
if [ -f tmp/pids/server.pid ]; then
  rm -f tmp/pids/server.pid
fi

# Wait for the database to be ready and run migrations with retries
MAX_ATTEMPTS=10
SLEEP_SECONDS=5
attempt=1

until bundle exec rails db:migrate RAILS_ENV=${RAILS_ENV:-production}; do
  if [ "$attempt" -ge "$MAX_ATTEMPTS" ]; then
    echo "Migrations failed after $attempt attempts, exiting."
    exit 1
  fi
  echo "Database not ready yet. Waiting $SLEEP_SECONDS seconds before retrying... (attempt: $attempt/$MAX_ATTEMPTS)"
  attempt=$((attempt + 1))
  sleep $SLEEP_SECONDS
done

# Ensure assets are present (precompiled in image; this is a no-op if already done)
if [ -d public/assets ] || [ -d app/assets/builds ]; then
  echo "Assets present"
else
  echo "Precompiling assets as fallback"
  bundle exec rails assets:precompile RAILS_ENV=${RAILS_ENV:-production}
fi

# Start the requested command (defaults to Puma)
exec "$@"
