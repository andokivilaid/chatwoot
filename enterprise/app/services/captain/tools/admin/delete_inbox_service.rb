class Captain::Tools::Admin::DeleteInboxService < Captain::Tools::Admin::BaseTool
  def self.name
    'delete_inbox'
  end

  description 'Delete an inbox.'
  param :inbox_id, type: :integer, desc: 'Inbox ID', required: true

  def execute(inbox_id:)
    capability_service(Captain::Capabilities::Inboxes::Delete, inbox_id: inbox_id)
  end
end
