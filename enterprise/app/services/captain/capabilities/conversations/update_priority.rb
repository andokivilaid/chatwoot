class Captain::Capabilities::Conversations::UpdatePriority < Captain::Capabilities::Base
  include Captain::Copilot::ConversationAccess

  def call(conversation_id:, priority:)
    conversation = accessible_conversation(account: account, user: user, display_id: conversation_id)
    return 'Conversation not found' if conversation.blank?

    authorize!(conversation, :show?)

    normalized_priority = priority == 'none' ? nil : priority
    return 'Invalid priority' unless normalized_priority.nil? || Conversation.priorities.key?(normalized_priority)

    conversation.update!(priority: normalized_priority)
    "Conversation ##{conversation.display_id} priority updated to #{priority}"
  rescue UnauthorizedError
    handle_unauthorized
  rescue ActiveRecord::RecordInvalid => e
    handle_record_invalid(e.record)
  end
end
