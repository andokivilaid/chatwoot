class Captain::Capabilities::Conversations::Search < Captain::Capabilities::Base
  include Captain::Copilot::ConversationAccess

  # rubocop:disable Metrics/ParameterLists -- keyword args mirror the search_conversations tool schema
  def call(query: nil, status: nil, inbox_id: nil, contact_id: nil, priority: nil, labels: nil)
    # rubocop:enable Metrics/ParameterLists
    conversations = permissible_conversations.where(
      attribute_filters(inbox_id: inbox_id, contact_id: contact_id, status: status, priority: priority)
    )
    conversations = conversations.tagged_with(labels, any: true) if labels.present?
    conversations = search_by_query(conversations, query) if query.present?

    return 'No conversations found' unless conversations.exists?

    total_count = conversations.count
    conversations = conversations.limit(100)

    <<~RESPONSE
      #{total_count > 100 ? "Found #{total_count} conversations (showing first 100)" : "Total number of conversations: #{total_count}"}
      #{conversations.map { |conversation| conversation.to_llm_text(include_contact_details: true, include_private_messages: true) }.join("\n---\n")}
    RESPONSE
  end

  private

  def attribute_filters(inbox_id:, contact_id:, status:, priority:)
    {
      inbox_id: inbox_id,
      contact_id: contact_id,
      status: (status if Conversation.statuses.key?(status)),
      priority: (priority if Conversation.priorities.key?(priority))
    }.compact_blank
  end

  def search_by_query(conversations, query)
    conversations.joins(:contact).where(
      'conversations.display_id::text ILIKE :query OR contacts.name ILIKE :query OR contacts.email ILIKE :query',
      query: "%#{query}%"
    )
  end

  def permissible_conversations
    accessible_conversations(account: account, user: user)
  end
end
