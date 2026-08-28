class Captain::Capabilities::Conversations::Search < Captain::Capabilities::Base
  include Captain::Copilot::ConversationAccess

  def call(query: nil, status: nil, inbox_id: nil, contact_id: nil, priority: nil, labels: nil)
    conversations = permissible_conversations
    conversations = conversations.where(inbox_id: inbox_id) if inbox_id.present?
    conversations = conversations.where(contact_id: contact_id) if contact_id.present?
    conversations = conversations.where(status: status) if valid_status?(status)
    conversations = conversations.where(priority: priority) if valid_priority?(priority)
    conversations = conversations.tagged_with(labels, any: true) if labels.present?

    if query.present?
      conversations = conversations.joins(:contact).where(
        'conversations.display_id::text ILIKE :query OR contacts.name ILIKE :query OR contacts.email ILIKE :query',
        query: "%#{query}%"
      )
    end

    return 'No conversations found' unless conversations.exists?

    total_count = conversations.count
    conversations = conversations.limit(100)

    <<~RESPONSE
      #{total_count > 100 ? "Found #{total_count} conversations (showing first 100)" : "Total number of conversations: #{total_count}"}
      #{conversations.map { |conversation| conversation.to_llm_text(include_contact_details: true, include_private_messages: true) }.join("\n---\n")}
    RESPONSE
  end

  private

  def valid_status?(status)
    status.present? && Conversation.statuses.key?(status)
  end

  def valid_priority?(priority)
    priority.present? && Conversation.priorities.key?(priority)
  end

  def permissible_conversations
    accessible_conversations(account: account, user: user)
  end
end
