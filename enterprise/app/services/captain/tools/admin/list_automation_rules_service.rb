class Captain::Tools::Admin::ListAutomationRulesService < Captain::Tools::Admin::BaseTool
  def self.name
    'list_automation_rules'
  end

  description 'List automation rules configured for the account'
  param :search, type: :string, desc: 'Optional filter by rule name (partial match)'
  param :active_only, type: :boolean, desc: 'When true, return only active rules'

  def execute(search: nil, active_only: false)
    capability_service(Captain::Capabilities::AutomationRules::List, search: search, active_only: active_only)
  end
end
