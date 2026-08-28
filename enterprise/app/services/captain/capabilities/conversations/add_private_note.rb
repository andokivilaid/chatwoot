class Captain::Capabilities::Conversations::AddPrivateNote < Captain::Capabilities::Base
  include Captain::Copilot::ConversationAccess

  def call(conversation_id:, content:)
    conversation = accessible_conversation(account: account, user: user, display_id: conversation_id)
    return 'Conversation not found' if conversation.blank?

    authorize!(conversation, :show?)

    conversation.messages.create!(
      account_id: account.id,
      inbox_id: conversation.inbox_id,
      message_type: :outgoing,
      content: content,
      private: true,
      sender: user
    )

    "Private note added to conversation ##{conversation.display_id}"
  rescue UnauthorizedError
    handle_unauthorized
  rescue ActiveRecord::RecordInvalid => e
    handle_record_invalid(e.record)
  end
end
