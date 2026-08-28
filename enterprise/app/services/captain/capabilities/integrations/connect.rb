class Captain::Capabilities::Integrations::Connect < Captain::Capabilities::Base
  OAUTH_INTEGRATION_IDS = %w[slack linear notion shopify].freeze

  def call(integration_id:, shop_domain: nil)
    return handle_unauthorized unless account_user&.administrator?

    validation_error = validate_connect_request(integration_id, shop_domain)
    return validation_error if validation_error.present?

    app = Integrations::App.find(id: integration_id)
    "Open the #{app.name} integration setup in the dashboard to complete OAuth authorization."
  end

  private

  def validate_connect_request(integration_id, shop_domain)
    return "Integration '#{integration_id}' is not connected via OAuth" unless OAUTH_INTEGRATION_IDS.include?(integration_id)
    return 'shop_domain is required for Shopify' if integration_id == 'shopify' && shop_domain.blank?

    app = Integrations::App.find(id: integration_id)
    return 'Integration not found' if app.blank?
    return 'Integration is not available for this account' unless app.active?(account)

    nil
  end
end
