class Captain::Capabilities::Inboxes::Delete < Captain::Capabilities::Base
  def call(inbox_id:)
    inbox = account.inboxes.find_by(id: inbox_id)
    return 'Inbox not found' if inbox.blank?

    authorize!(inbox, :destroy?)
    inbox.destroy!

    "Inbox ##{inbox_id} deleted successfully"
  rescue UnauthorizedError
    handle_unauthorized
  end
end
