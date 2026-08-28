class Captain::Tools::Admin::ListLabelsService < Captain::Tools::Admin::BaseTool
  def self.name
    'list_labels'
  end

  description 'List all labels configured for the account'
  param :search, type: :string, desc: 'Optional filter by label title (partial match)'

  def execute(search: nil)
    capability_service(Captain::Capabilities::Labels::List, search: search)
  end
end
