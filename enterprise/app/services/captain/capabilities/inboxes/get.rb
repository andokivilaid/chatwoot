class Captain::Capabilities::Inboxes::Get < Captain::Capabilities::Base
  def call(inbox_id:)
    inbox = account.inboxes.find_by(id: inbox_id)
    return 'Inbox not found' if inbox.blank?

    authorize!(inbox, :show?)

    format_inbox(inbox)
  rescue UnauthorizedError
    handle_unauthorized
  end
end
