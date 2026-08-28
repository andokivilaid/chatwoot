class Captain::Capabilities::AutomationRules::List < Captain::Capabilities::Base
  def call(search: nil, active_only: false)
    authorize!(AutomationRule, :index?)

    rules = account.automation_rules
    rules = rules.active if ActiveModel::Type::Boolean.new.cast(active_only)
    rules = rules.where('name ILIKE ?', "%#{search}%") if search.present?

    return 'No automation rules found' if rules.none?

    rules.limit(100).map { |rule| format_automation_rule(rule) }.join("\n---\n")
  rescue UnauthorizedError
    handle_unauthorized
  end
end
