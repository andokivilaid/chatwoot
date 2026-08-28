class Captain::Capabilities::Inboxes::List < Captain::Capabilities::Base
  def call(search: nil)
    authorize!(Inbox, :index?)

    inboxes = account.inboxes
    inboxes = inboxes.where('name ILIKE ?', "%#{search}%") if search.present?

    return 'No inboxes found' if inboxes.none?

    inboxes.limit(100).map { |inbox| format_inbox(inbox) }.join("\n---\n")
  rescue UnauthorizedError
    handle_unauthorized
  end
end
