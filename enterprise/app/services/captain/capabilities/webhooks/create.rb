class Captain::Capabilities::Webhooks::Create < Captain::Capabilities::Base
  def call(name:, url:, subscriptions_json:, inbox_id: nil)
    webhook = account.webhooks.new(name: name, url: url, inbox_id: inbox_id)
    authorize!(webhook, :create?)

    subscriptions = parse_json_array(subscriptions_json, 'subscriptions_json')
    return subscriptions if json_parse_error?(subscriptions)
    return 'subscriptions_json is required' if subscriptions.blank?

    webhook.subscriptions = subscriptions
    webhook.save!

    "Webhook created successfully.\n#{format_webhook(webhook)}"
  rescue UnauthorizedError
    handle_unauthorized
  rescue ActiveRecord::RecordInvalid => e
    handle_record_invalid(e.record)
  end
end
