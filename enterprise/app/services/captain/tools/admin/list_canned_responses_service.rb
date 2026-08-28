class Captain::Tools::Admin::ListCannedResponsesService < Captain::Tools::Admin::BaseTool
  def self.name
    'list_canned_responses'
  end

  description 'List canned responses configured for the account'
  param :search, type: :string, desc: 'Optional filter by short code or content (partial match)'

  def execute(search: nil)
    capability_service(Captain::Capabilities::CannedResponses::List, search: search)
  end
end
