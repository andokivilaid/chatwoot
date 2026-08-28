class Captain::Tools::Admin::DeleteMacroService < Captain::Tools::Admin::BaseTool
  def self.name
    'delete_macro'
  end

  description 'Delete a macro.'
  param :macro_id, type: :integer, desc: 'Macro ID', required: true

  def execute(macro_id:)
    capability_service(Captain::Capabilities::Macros::Delete, macro_id: macro_id)
  end
end
