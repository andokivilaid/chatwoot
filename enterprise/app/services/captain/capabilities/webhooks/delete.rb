class Captain::Capabilities::Webhooks::Delete < Captain::Capabilities::Base
  def call(webhook_id:)
    webhook = account.webhooks.find_by(id: webhook_id)
    return 'Webhook not found' if webhook.blank?

    authorize!(webhook, :destroy?)

    name = webhook.name.presence || webhook.url
    webhook.destroy!
    "Webhook '#{name}' deleted successfully."
  rescue UnauthorizedError
    handle_unauthorized
  end
end
