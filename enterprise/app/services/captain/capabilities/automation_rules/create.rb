class Captain::Capabilities::AutomationRules::Create < Captain::Capabilities::Base
  def call(name:, event_name:, conditions_json:, actions_json:, description: nil, active: true, execution_delay: nil)
    authorize!(AutomationRule.new(account: account), :create?)

    conditions = parse_json_array(conditions_json, 'conditions_json')
    return conditions if parse_error?(conditions)

    actions = parse_json_array(actions_json, 'actions_json')
    return actions if parse_error?(actions)

    return 'Delayed automations are not enabled for this account' if execution_delay.present? && !account.feature_enabled?('delayed_automations')

    rule = account.automation_rules.create!(
      name: name,
      description: description,
      event_name: event_name,
      active: active.nil? || active,
      execution_delay: execution_delay,
      conditions: conditions,
      actions: actions
    )

    "Automation rule created successfully.\n#{format_automation_rule(rule)}"
  rescue UnauthorizedError
    handle_unauthorized
  rescue ActiveRecord::RecordInvalid => e
    handle_record_invalid(e.record)
  end

  private

  def parse_json_array(json_string, param_name)
    return [] if json_string.blank?

    parsed = JSON.parse(json_string)
    return parsed if parsed.is_a?(Array)

    "Invalid #{param_name}: expected a JSON array"
  rescue JSON::ParserError
    "Invalid #{param_name}: could not parse JSON"
  end

  def parse_error?(value)
    value.is_a?(String) && value.start_with?('Invalid ')
  end
end
