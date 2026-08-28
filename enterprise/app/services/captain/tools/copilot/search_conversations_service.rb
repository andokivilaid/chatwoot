class Captain::Tools::Copilot::SearchConversationsService < Captain::Tools::BaseTool
  include Captain::Copilot::ConversationAccess

  def self.name
    'search_conversations'
  end
  description 'Search conversations based on parameters'

  param :status, type: :string, desc: 'Status of the conversation (open, resolved, pending, snoozed). Leave empty to search all statuses.'
  param :contact_id, type: :number, desc: 'Contact id'
  param :priority, type: :string, desc: 'Priority of conversation (low, medium, high, urgent). Leave empty to search all priorities.'
  param :labels, type: :string, desc: 'Labels available'

  def execute(status: nil, contact_id: nil, priority: nil, labels: nil)
    capability_service(
      Captain::Capabilities::Conversations::Search,
      status: status,
      contact_id: contact_id,
      priority: priority,
      labels: labels
    )
  end

  def active?
    user_has_permission('conversation_manage') ||
      user_has_permission('conversation_unassigned_manage') ||
      user_has_permission('conversation_participating_manage')
  end

  private

  def capability_service(service_class, **params)
    service_class.new(account: @assistant.account, user: @user).call(**params)
  end
end
