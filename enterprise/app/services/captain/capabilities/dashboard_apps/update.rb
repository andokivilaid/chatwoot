class Captain::Capabilities::DashboardApps::Update < Captain::Capabilities::Base
  def call(dashboard_app_id:, title: nil, content_json: nil)
    dashboard_app = account.dashboard_apps.find_by(id: dashboard_app_id)
    return 'Dashboard app not found' if dashboard_app.blank?

    authorize!(dashboard_app, :update?)

    updates = {}
    updates[:title] = title if title.present?

    if content_json.present?
      content = parse_json_array(content_json, 'content_json')
      return content if json_parse_error?(content)

      updates[:content] = content
    end

    return 'No changes were provided' if updates.blank?

    dashboard_app.update!(updates)
    "Dashboard app updated successfully.\n#{format_dashboard_app(dashboard_app.reload)}"
  rescue UnauthorizedError
    handle_unauthorized
  rescue ActiveRecord::RecordInvalid => e
    handle_record_invalid(e.record)
  end
end
