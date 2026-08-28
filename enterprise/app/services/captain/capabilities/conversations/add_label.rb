class Captain::Capabilities::Conversations::AddLabel < Captain::Capabilities::Base
  include Captain::Copilot::ConversationAccess

  def call(conversation_id:, label_name:)
    conversation = accessible_conversation(account: account, user: user, display_id: conversation_id)
    return 'Conversation not found' if conversation.blank?

    authorize!(conversation, :show?)

    normalized_label = label_name.strip.downcase
    label = account.labels.find_by('LOWER(title) = ?', normalized_label)
    return 'Label not found' if label.blank?

    conversation.add_labels(normalized_label)
    "Label '#{normalized_label}' added to conversation ##{conversation.display_id}"
  rescue UnauthorizedError
    handle_unauthorized
  end
end
