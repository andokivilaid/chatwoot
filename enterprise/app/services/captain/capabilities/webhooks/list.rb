class Captain::Capabilities::Webhooks::List < Captain::Capabilities::Base
  def call
    webhook = Webhook.new(account: account)
    authorize!(webhook, :index?)

    webhooks = account.webhooks
    return 'No webhooks found' if webhooks.none?

    webhooks.map { |record| format_webhook(record) }.join("\n---\n")
  rescue UnauthorizedError
    handle_unauthorized
  end
end
