class Captain::Capabilities::IntegrationHooks::Create < Captain::Capabilities::Base
  OAUTH_INTEGRATION_IDS = %w[slack linear notion shopify].freeze

  def call(app_id:, settings_json: nil, inbox_id: nil, status: nil)
    return handle_unauthorized unless account_user&.administrator?

    validation_error = validate_create_request(app_id)
    return validation_error if validation_error.present?

    hook = build_hook(app_id: app_id, inbox_id: inbox_id, status: status, settings_json: settings_json)
    return hook if json_parse_error?(hook)

    authorize!(hook, :create?)
    hook.save!
    "Integration hook created successfully.\n#{format_integration_hook(hook)}"
  rescue UnauthorizedError
    handle_unauthorized
  rescue ActiveRecord::RecordInvalid => e
    handle_record_invalid(e.record)
  end

  private

  def validate_create_request(app_id)
    return "Integration '#{app_id}' must be connected via OAuth in the dashboard" if OAUTH_INTEGRATION_IDS.include?(app_id)

    app = Integrations::App.find(id: app_id)
    return 'Integration not found' if app.blank?
    return 'Integration is not available for this account' unless app.active?(account)

    nil
  end

  def build_hook(app_id:, inbox_id:, status:, settings_json:)
    hook = account.hooks.new(app_id: app_id, inbox_id: inbox_id, status: status.presence || 'enabled')
    return hook if settings_json.blank?

    settings = parse_json_object(settings_json, 'settings_json')
    return settings if json_parse_error?(settings)

    hook.settings = settings
    hook
  end
end
