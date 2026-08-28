class Captain::Capabilities::Conversations::Resolve < Captain::Capabilities::Base
  include Captain::Copilot::ConversationAccess

  def call(conversation_id:, reason: nil)
    conversation = accessible_conversation(account: account, user: user, display_id: conversation_id)
    return 'Conversation not found' if conversation.blank?

    authorize!(conversation, :show?)
    return "Conversation ##{conversation.display_id} is already resolved" if conversation.resolved?

    conversation.resolved!
    "Conversation ##{conversation.display_id} resolved#{" (Reason: #{reason})" if reason.present?}"
  rescue UnauthorizedError
    handle_unauthorized
  end
end
