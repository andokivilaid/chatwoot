class Captain::Capabilities::Integrations::List < Captain::Capabilities::Base
  def call
    return handle_unauthorized unless account_user&.administrator?

    apps = Integrations::App.all.select { |app| app.active?(account) }
    return 'No integrations found' if apps.none?

    apps.map { |app| format_integration_app(app, account: account) }.join("\n---\n")
  end
end
