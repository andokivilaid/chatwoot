class Captain::Tools::Admin::GetInboxService < Captain::Tools::Admin::BaseTool
  def self.name
    'get_inbox'
  end

  description 'Get detailed settings for a specific inbox'
  param :inbox_id, type: :integer, desc: 'ID of the inbox to retrieve', required: true

  def execute(inbox_id:)
    capability_service(Captain::Capabilities::Inboxes::Get, inbox_id: inbox_id)
  end
end
