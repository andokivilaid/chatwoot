#!/usr/bin/env bash
# Enable enterprise pricing plan and all premium account features (self-hosted EE).
# Safe to re-run after deploy; persists in Postgres.
set -euo pipefail

cd /docker/chatwoot

docker compose exec -T rails bundle exec rails runner "
  c = InstallationConfig.find_or_initialize_by(name: 'INSTALLATION_PRICING_PLAN')
  c.update!(value: 'enterprise', locked: false)
  GlobalConfig.clear_cache

  premium_names = YAML.safe_load(File.read(Rails.root.join('config/features.yml').to_s))
    .select { |f| f['premium'] }
    .pluck('name')

  Account.find_each do |account|
    account.enable_features!(*premium_names)
    puts \"Account #{account.id} (#{account.name}): enabled #{premium_names.size} premium features\"
  end

  puts \"INSTALLATION_PRICING_PLAN=#{ChatwootHub.pricing_plan}\"
"

echo "Enterprise features enabled."
