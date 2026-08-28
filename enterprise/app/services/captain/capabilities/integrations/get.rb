class Captain::Capabilities::Integrations::Get < Captain::Capabilities::Base
  OAUTH_INTEGRATION_IDS = %w[slack linear notion shopify].freeze

  def call(integration_id:)
    return handle_unauthorized unless account_user&.administrator?

    app = Integrations::App.find(id: integration_id)
    return 'Integration not found' if app.blank?

    hooks = account.hooks.where(app_id: integration_id)
    summary = format_integration_app(app, account: account)
    hook_details = hooks.map { |hook| format_integration_hook(hook) }

    output = [summary]
    output << "OAuth setup required in browser: #{app.action}" if OAUTH_INTEGRATION_IDS.include?(integration_id)
    output << "Connected hooks:\n#{hook_details.join("\n---\n")}" if hook_details.any?
    output.join("\n\n")
  end
end
