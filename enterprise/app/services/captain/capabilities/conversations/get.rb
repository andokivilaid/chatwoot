class Captain::Capabilities::Conversations::Get < Captain::Capabilities::Base
  include Captain::Copilot::ConversationAccess

  def call(conversation_id:)
    conversation = accessible_conversation(account: account, user: user, display_id: conversation_id)
    return 'Conversation not found' if conversation.blank?

    conversation.to_llm_text(include_private_messages: true)
  end
end
