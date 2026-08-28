class Captain::Capabilities::DashboardApps::Delete < Captain::Capabilities::Base
  def call(dashboard_app_id:)
    dashboard_app = account.dashboard_apps.find_by(id: dashboard_app_id)
    return 'Dashboard app not found' if dashboard_app.blank?

    authorize!(dashboard_app, :destroy?)

    title = dashboard_app.title
    dashboard_app.destroy!
    "Dashboard app '#{title}' deleted successfully."
  rescue UnauthorizedError
    handle_unauthorized
  end
end
