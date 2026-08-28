class Captain::Tools::Admin::CreateAutomationRuleService < Captain::Tools::Admin::BaseTool
  def self.name
    'create_automation_rule'
  end

  description 'Create an automation rule.'
  param :name, type: :string, desc: 'Automation rule name', required: true
  param :event_name, type: :string, desc: 'Trigger event (e.g. conversation_created, conversation_updated, message_created)', required: true
  param :conditions_json, type: :string, desc: 'Conditions as a JSON array', required: true
  param :actions_json, type: :string, desc: 'Actions as a JSON array', required: true
  param :description, type: :string, desc: 'Automation rule description'
  param :active, type: :boolean, desc: 'Whether the rule is active'
  param :execution_delay, type: :integer, desc: 'Delay in minutes before actions run (requires delayed_automations feature)'

  def execute(name:, event_name:, conditions_json:, actions_json:, description: nil, active: true, execution_delay: nil)
    capability_service(
      Captain::Capabilities::AutomationRules::Create,
      name: name,
      event_name: event_name,
      conditions_json: conditions_json,
      actions_json: actions_json,
      description: description,
      active: active,
      execution_delay: execution_delay
    )
  end
end
