class Captain::Tools::Admin::UpdateMacroService < Captain::Tools::Admin::BaseTool
  def self.name
    'update_macro'
  end

  description 'Update a macro.'
  param :macro_id, type: :integer, desc: 'Macro ID', required: true
  param :name, type: :string, desc: 'Macro name'
  param :actions_json, type: :string, desc: 'Actions as a JSON array'
  param :visibility, type: :string, desc: 'Macro visibility: global or personal'

  def execute(macro_id:, name: nil, actions_json: nil, visibility: nil)
    capability_service(
      Captain::Capabilities::Macros::Update,
      macro_id: macro_id,
      name: name,
      actions_json: actions_json,
      visibility: visibility
    )
  end
end
