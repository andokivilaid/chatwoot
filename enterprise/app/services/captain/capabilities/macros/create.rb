class Captain::Capabilities::Macros::Create < Captain::Capabilities::Base
  def call(name:, actions_json:, visibility: 'global')
    actions = parse_json_array(actions_json, 'actions_json')
    return actions if parse_error?(actions)

    macro = account.macros.new(
      name: name,
      visibility: visibility,
      actions: actions,
      created_by_id: user.id,
      updated_by_id: user.id
    )
    authorize!(macro, :create?)

    macro.save!
    "Macro created successfully.\n#{format_macro(macro)}"
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
