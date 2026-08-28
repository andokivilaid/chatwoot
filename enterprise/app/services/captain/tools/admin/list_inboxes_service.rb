class Captain::Tools::Admin::ListInboxesService < Captain::Tools::Admin::BaseTool
  def self.name
    'list_inboxes'
  end

  description 'List all inboxes configured for the account'
  param :search, type: :string, desc: 'Optional filter by inbox name (partial match)'

  def execute(search: nil)
    capability_service(Captain::Capabilities::Inboxes::List, search: search)
  end
end
