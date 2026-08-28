class Captain::Capabilities::IntegrationHooks::List < Captain::Capabilities::Base
  def call(app_id: nil)
    return handle_unauthorized unless account_user&.administrator?

    hooks = account.hooks
    hooks = hooks.where(app_id: app_id) if app_id.present?
    return 'No integration hooks found' if hooks.none?

    hooks.map { |hook| format_integration_hook(hook) }.join("\n---\n")
  end
end
