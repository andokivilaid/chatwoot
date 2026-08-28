class Captain::Tools::Admin::ListMacrosService < Captain::Tools::Admin::BaseTool
  def self.name
    'list_macros'
  end

  description 'List macros configured for the account'
  param :search, type: :string, desc: 'Optional filter by macro name (partial match)'

  def execute(search: nil)
    capability_service(Captain::Capabilities::Macros::List, search: search)
  end
end
