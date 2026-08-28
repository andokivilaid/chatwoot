#!/usr/bin/env bash
set -euo pipefail

cd /docker/chatwoot

docker compose pull
docker compose run --rm rails bundle exec rails db:migrate
docker compose up -d

echo "Chatwoot updated."
