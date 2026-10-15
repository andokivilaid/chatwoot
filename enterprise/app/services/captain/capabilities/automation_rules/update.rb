class Captain::Capabilities::AutomationRules::Update < Captain::Capabilities::Base
  # rubocop:disable Metrics/ParameterLists -- keyword args mirror the update_automation_rule tool schema
  def call(automation_rule_id:, name: nil, event_name: nil, conditions_json: nil, actions_json: nil,
           description: nil, active: nil, execution_delay: nil)
    # rubocop:enable Metrics/ParameterLists
    rule = account.automation_rules.find_by(id: automation_rule_id)
    return 'Automation rule not found' if rule.blank?

    authorize!(rule, :update?)

    json_updates = parsed_json_updates(conditions_json, actions_json)
    parse_error = json_updates.values.find { |value| json_parse_error?(value) }
    return parse_error if parse_error

    updates = { name: name, description: description, event_name: event_name, active: active, execution_delay: execution_delay }
              .compact.merge(json_updates)
    return 'No changes were provided' if updates.blank?
    return 'Delayed automations are not enabled for this account' if delayed_automations_blocked?(updates[:execution_delay])

    rule.update!(updates)
    "Automation rule updated successfully.\n#{format_automation_rule(rule)}"
  rescue UnauthorizedError
    handle_unauthorized
  rescue ActiveRecord::RecordInvalid => e
    handle_record_invalid(e.record)
  end

  private

  def parsed_json_updates(conditions_json, actions_json)
    {}.tap do |updates|
      updates[:conditions] = parse_json_array(conditions_json, 'conditions_json') if conditions_json.present?
      updates[:actions] = parse_json_array(actions_json, 'actions_json') if actions_json.present?
    end
  end

  def delayed_automations_blocked?(execution_delay)
    execution_delay.present? && !account.feature_enabled?('delayed_automations')
  end
end
