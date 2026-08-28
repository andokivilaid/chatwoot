class Captain::Tools::Admin::GetMacroService < Captain::Tools::Admin::BaseTool
  def self.name
    'get_macro'
  end

  description 'Get detailed settings for a specific macro'
  param :macro_id, type: :integer, desc: 'ID of the macro to retrieve', required: true

  def execute(macro_id:)
    capability_service(Captain::Capabilities::Macros::Get, macro_id: macro_id)
  end
end
