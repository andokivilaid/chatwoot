class Captain::Capabilities::Webhooks::Update < Captain::Capabilities::Base
  def call(webhook_id:, name: nil, url: nil, subscriptions_json: nil, inbox_id: nil)
    webhook = account.webhooks.find_by(id: webhook_id)
    return 'Webhook not found' if webhook.blank?

    authorize!(webhook, :update?)

    updates = webhook_updates(name: name, url: url, inbox_id: inbox_id, subscriptions_json: subscriptions_json)
    return updates if json_parse_error?(updates)
    return 'No changes were provided' if updates.blank?

    webhook.update!(updates)
    "Webhook updated successfully.\n#{format_webhook(webhook.reload)}"
  rescue UnauthorizedError
    handle_unauthorized
  rescue ActiveRecord::RecordInvalid => e
    handle_record_invalid(e.record)
  end

  private

  def webhook_updates(name:, url:, inbox_id:, subscriptions_json:)
    updates = {}
    updates[:name] = name if name.present?
    updates[:url] = url if url.present?
    updates[:inbox_id] = inbox_id unless inbox_id.nil?

    return updates if subscriptions_json.blank?

    subscriptions = parse_json_array(subscriptions_json, 'subscriptions_json')
    return subscriptions if json_parse_error?(subscriptions)

    updates[:subscriptions] = subscriptions
    updates
  end
end
