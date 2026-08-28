class Captain::Capabilities::IntegrationHooks::Delete < Captain::Capabilities::Base
  def call(hook_id:)
    hook = account.hooks.find_by(id: hook_id)
    return 'Integration hook not found' if hook.blank?

    authorize!(hook, :destroy?)

    app_id = hook.app_id
    hook.destroy!
    "Integration hook for '#{app_id}' deleted successfully."
  rescue UnauthorizedError
    handle_unauthorized
  end
end
