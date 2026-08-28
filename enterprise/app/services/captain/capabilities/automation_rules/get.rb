class Captain::Capabilities::AutomationRules::Get < Captain::Capabilities::Base
  def call(automation_rule_id:)
    rule = account.automation_rules.find_by(id: automation_rule_id)
    return 'Automation rule not found' if rule.blank?

    authorize!(rule, :show?)
    format_automation_rule(rule)
  rescue UnauthorizedError
    handle_unauthorized
  end
end
