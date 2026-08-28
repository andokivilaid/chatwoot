class Captain::Capabilities::DashboardApps::List < Captain::Capabilities::Base
  def call
    dashboard_app = DashboardApp.new(account: account)
    authorize!(dashboard_app, :index?)

    dashboard_apps = account.dashboard_apps
    return 'No dashboard apps found' if dashboard_apps.none?

    dashboard_apps.map { |record| format_dashboard_app(record) }.join("\n---\n")
  rescue UnauthorizedError
    handle_unauthorized
  end
end
