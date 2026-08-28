class Captain::Capabilities::Conversations::Assign < Captain::Capabilities::Base
  include Captain::Copilot::ConversationAccess

  def call(conversation_id:, assignee_id:)
    conversation = accessible_conversation(account: account, user: user, display_id: conversation_id)
    return 'Conversation not found' if conversation.blank?

    authorize!(conversation, :show?)

    assignee = account.users.find_by(id: assignee_id)
    return 'Assignee not found' if assignee.blank?

    conversation.update!(assignee: assignee)
    "Conversation ##{conversation.display_id} assigned to #{assignee.name}"
  rescue UnauthorizedError
    handle_unauthorized
  rescue ActiveRecord::RecordInvalid => e
    handle_record_invalid(e.record)
  end
end
