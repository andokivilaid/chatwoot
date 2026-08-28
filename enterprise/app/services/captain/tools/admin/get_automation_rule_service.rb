class Captain::Tools::Admin::GetAutomationRuleService < Captain::Tools::Admin::BaseTool
  def self.name
    'get_automation_rule'
  end

  description 'Get detailed settings for a specific automation rule'
  param :automation_rule_id, type: :integer, desc: 'ID of the automation rule to retrieve', required: true

  def execute(automation_rule_id:)
    capability_service(Captain::Capabilities::AutomationRules::Get, automation_rule_id: automation_rule_id)
  end
end
