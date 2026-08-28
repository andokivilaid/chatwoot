class Captain::Capabilities::Macros::Update < Captain::Capabilities::Base
  def call(macro_id:, name: nil, actions_json: nil, visibility: nil)
    macro = account.macros.find_by(id: macro_id)
    return 'Macro not found' if macro.blank?

    authorize!(macro, :update?)

    updates = {}.tap do |hash|
      hash[:name] = name unless name.nil?
      hash[:visibility] = visibility unless visibility.nil?
      hash[:updated_by_id] = user.id
    end

    if actions_json.present?
      actions = parse_json_array(actions_json)
      return 'Invalid actions_json: expected a JSON array' unless actions.is_a?(Array)

      updates[:actions] = actions
    end

    return 'No changes were provided' if updates.except(:updated_by_id).blank?

    macro.update!(updates)
    "Macro updated successfully.\n#{format_macro(macro)}"
  rescue UnauthorizedError
    handle_unauthorized
  rescue ActiveRecord::RecordInvalid => e
    handle_record_invalid(e.record)
  end

  private

  def parse_json_array(json_string)
    JSON.parse(json_string)
  rescue JSON::ParserError
    nil
  end
end
