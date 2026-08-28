class Captain::Tools::Copilot::GetConversationService < Captain::Tools::BaseTool
  include Captain::Copilot::ConversationAccess

  def self.name
    'get_conversation'
  end
  description 'Get details of a conversation including messages and contact information'

  param :conversation_id, type: :integer, desc: 'ID of the conversation to retrieve', required: true

  def execute(conversation_id:)
    capability_service(Captain::Capabilities::Conversations::Get, conversation_id: conversation_id)
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
