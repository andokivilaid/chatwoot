class Captain::Tools::Admin::UpdateAutomationRuleService < Captain::Tools::Admin::BaseTool
  def self.name
    'update_automation_rule'
  end

  description 'Update an automation rule.'
  param :automation_rule_id, type: :integer, desc: 'Automation rule ID', required: true
  param :name, type: :string, desc: 'Automation rule name'
  param :event_name, type: :string, desc: 'Trigger event'
  param :conditions_json, type: :string, desc: 'Conditions as a JSON array'
  param :actions_json, type: :string, desc: 'Actions as a JSON array'
  param :description, type: :string, desc: 'Automation rule description'
  param :active, type: :boolean, desc: 'Whether the rule is active'
  param :execution_delay, type: :integer, desc: 'Delay in minutes before actions run'

  def execute(automation_rule_id:, name: nil, event_name: nil, conditions_json: nil, actions_json: nil,
              description: nil, active: nil, execution_delay: nil)
    capability_service(
      Captain::Capabilities::AutomationRules::Update,
      automation_rule_id: automation_rule_id,
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
