class Captain::Capabilities::AutomationRules::Update < Captain::Capabilities::Base
  def call(automation_rule_id:, name: nil, event_name: nil, conditions_json: nil, actions_json: nil,
           description: nil, active: nil, execution_delay: nil)
    rule = account.automation_rules.find_by(id: automation_rule_id)
    return 'Automation rule not found' if rule.blank?

    authorize!(rule, :update?)

    updates = {}.tap do |hash|
      hash[:name] = name unless name.nil?
      hash[:description] = description unless description.nil?
      hash[:event_name] = event_name unless event_name.nil?
      hash[:active] = active unless active.nil?
      hash[:execution_delay] = execution_delay unless execution_delay.nil?
    end

    if conditions_json.present?
      conditions = parse_json_array(conditions_json, 'conditions_json')
      return conditions if parse_error?(conditions)

      updates[:conditions] = conditions
    end

    if actions_json.present?
      actions = parse_json_array(actions_json, 'actions_json')
      return actions if parse_error?(actions)

      updates[:actions] = actions
    end

    return 'No changes were provided' if updates.blank?

    if updates.key?(:execution_delay) && updates[:execution_delay].present? && !account.feature_enabled?('delayed_automations')
      return 'Delayed automations are not enabled for this account'
    end

    rule.update!(updates)
    "Automation rule updated successfully.\n#{format_automation_rule(rule)}"
  rescue UnauthorizedError
    handle_unauthorized
  rescue ActiveRecord::RecordInvalid => e
    handle_record_invalid(e.record)
  end

  private

  def parse_json_array(json_string, param_name)
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
