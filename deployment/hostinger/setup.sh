#!/usr/bin/env bash
set -euo pipefail

DEPLOY_DIR="${DEPLOY_DIR:-/docker/chatwoot}"
CHATWOOT_HOST="${CHATWOOT_HOST:-chatwoot.srv1602732.hstgr.cloud}"
CHATWOOT_IMAGE="${CHATWOOT_IMAGE:-chatwoot/chatwoot:v4.17.1}"

mkdir -p "$DEPLOY_DIR"
cd "$DEPLOY_DIR"

if [[ ! -f .env ]]; then
  SECRET_KEY_BASE="$(openssl rand -hex 64)"
  POSTGRES_PASSWORD="$(openssl rand -hex 32)"
  REDIS_PASSWORD="$(openssl rand -hex 32)"
  ENC_PRIMARY="$(openssl rand -hex 32)"
  ENC_DETERMINISTIC="$(openssl rand -hex 32)"
  ENC_SALT="$(openssl rand -hex 32)"

  cat > .env <<EOF
CHATWOOT_HOST=${CHATWOOT_HOST}
CHATWOOT_IMAGE=${CHATWOOT_IMAGE}

SECRET_KEY_BASE=${SECRET_KEY_BASE}
ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY=${ENC_PRIMARY}
ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY=${ENC_DETERMINISTIC}
ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT=${ENC_SALT}

FRONTEND_URL=https://${CHATWOOT_HOST}
FORCE_SSL=true
RAILS_ENV=production
NODE_ENV=production
INSTALLATION_ENV=docker
ENABLE_ACCOUNT_SIGNUP=false

POSTGRES_HOST=postgres
POSTGRES_USERNAME=postgres
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
POSTGRES_DATABASE=chatwoot

REDIS_URL=redis://redis:6379
REDIS_PASSWORD=${REDIS_PASSWORD}

MAILER_SENDER_EMAIL=Chatwoot <noreply@${CHATWOOT_HOST}>
EOF
  chmod 600 .env
  echo "Created ${DEPLOY_DIR}/.env"
else
  echo "Keeping existing ${DEPLOY_DIR}/.env"
fi

docker compose pull
docker compose run --rm rails bundle exec rails db:chatwoot_prepare
docker compose up -d

echo "Chatwoot is starting at https://${CHATWOOT_HOST}"
