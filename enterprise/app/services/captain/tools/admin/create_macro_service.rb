class Captain::Tools::Admin::CreateMacroService < Captain::Tools::Admin::BaseTool
  def self.name
    'create_macro'
  end

  description 'Create a macro.'
  param :name, type: :string, desc: 'Macro name', required: true
  param :actions_json, type: :string, desc: 'Actions as a JSON array', required: true
  param :visibility, type: :string, desc: 'Macro visibility: global or personal'

  def execute(name:, actions_json:, visibility: 'global')
    capability_service(
      Captain::Capabilities::Macros::Create,
      name: name,
      actions_json: actions_json,
      visibility: visibility
    )
  end
end
