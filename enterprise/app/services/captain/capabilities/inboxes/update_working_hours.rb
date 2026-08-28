class Captain::Capabilities::Inboxes::UpdateWorkingHours < Captain::Capabilities::Base
  def call(inbox_id:, working_hours_json:)
    inbox = account.inboxes.find_by(id: inbox_id)
    return 'Inbox not found' if inbox.blank?

    authorize!(inbox, :update?)

    working_hours = parse_json_array(working_hours_json, 'working_hours_json')
    return working_hours if json_parse_error?(working_hours)
    return 'No working hours were provided' if working_hours.blank?

    inbox.update_working_hours(working_hours)
    "Inbox working hours updated successfully.\n#{format_inbox(inbox.reload)}"
  rescue UnauthorizedError
    handle_unauthorized
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
    "Failed to update inbox working hours: #{e.message}"
  end
end
