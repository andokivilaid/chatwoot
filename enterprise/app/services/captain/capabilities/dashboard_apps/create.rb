class Captain::Capabilities::DashboardApps::Create < Captain::Capabilities::Base
  def call(title:, content_json:)
    dashboard_app = account.dashboard_apps.new(title: title, user_id: user.id)
    authorize!(dashboard_app, :create?)

    content = parse_json_array(content_json, 'content_json')
    return content if json_parse_error?(content)
    return 'content_json is required' if content.blank?

    dashboard_app.content = content
    dashboard_app.save!

    "Dashboard app created successfully.\n#{format_dashboard_app(dashboard_app)}"
  rescue UnauthorizedError
    handle_unauthorized
  rescue ActiveRecord::RecordInvalid => e
    handle_record_invalid(e.record)
  end
end
