#!/usr/bin/env bash
# Enable enterprise pricing plan and all premium account features (self-hosted EE).
# Safe to re-run after deploy; persists in Postgres.
set -euo pipefail

cd /docker/chatwoot

docker compose exec -T rails bundle exec rails runner "
  [
    ['INSTALLATION_PRICING_PLAN', 'enterprise'],
    ['INSTALLATION_PRICING_PLAN_QUANTITY', 100]
  ].each do |name, value|
    InstallationConfig.find_or_initialize_by(name: name).update!(value: value, locked: false)
  end
  GlobalConfig.clear_cache

  premium_names = YAML.safe_load(File.read(Rails.root.join('config/features.yml').to_s))
    .select { |f| f['premium'] }
    .pluck('name')

  Account.find_each do |account|
    account.enable_features!(*premium_names)
    puts \"Account #{account.id} (#{account.name}): enabled #{premium_names.size} premium features\"
  end

  puts \"INSTALLATION_PRICING_PLAN=#{ChatwootHub.pricing_plan}\"
  puts \"INSTALLATION_PRICING_PLAN_QUANTITY=#{ChatwootHub.pricing_plan_quantity}\"
"

echo "Enterprise features enabled."
