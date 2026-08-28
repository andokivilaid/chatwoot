class Captain::Tools::Admin::DeleteAutomationRuleService < Captain::Tools::Admin::BaseTool
  def self.name
    'delete_automation_rule'
  end

  description 'Delete an automation rule.'
  param :automation_rule_id, type: :integer, desc: 'Automation rule ID', required: true

  def execute(automation_rule_id:)
    capability_service(Captain::Capabilities::AutomationRules::Delete, automation_rule_id: automation_rule_id)
  end
end
