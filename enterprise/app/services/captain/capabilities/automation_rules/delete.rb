class Captain::Capabilities::AutomationRules::Delete < Captain::Capabilities::Base
  def call(automation_rule_id:)
    rule = account.automation_rules.find_by(id: automation_rule_id)
    return 'Automation rule not found' if rule.blank?

    authorize!(rule, :destroy?)
    rule.destroy!

    "Automation rule ##{automation_rule_id} deleted successfully"
  rescue UnauthorizedError
    handle_unauthorized
  end
end
