class Captain::Capabilities::IntegrationHooks::Update < Captain::Capabilities::Base
  def call(hook_id:, status: nil, settings_json: nil)
    hook = account.hooks.find_by(id: hook_id)
    return 'Integration hook not found' if hook.blank?

    authorize!(hook, :update?)

    updates = {}
    updates[:status] = status if status.present?

    if settings_json.present?
      settings = parse_json_object(settings_json, 'settings_json')
      return settings if json_parse_error?(settings)

      updates[:settings] = settings
    end

    return 'No changes were provided' if updates.blank?

    hook.update!(updates)
    "Integration hook updated successfully.\n#{format_integration_hook(hook.reload)}"
  rescue UnauthorizedError
    handle_unauthorized
  rescue ActiveRecord::RecordInvalid => e
    handle_record_invalid(e.record)
  end
end
