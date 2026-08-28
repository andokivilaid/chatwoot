class Captain::Capabilities::Campaigns::Create < Captain::Capabilities::Base
  def call(title:, message:, inbox_id:, description: nil, enabled: true, trigger_rules_json: nil, audience_json: nil)
    campaign = account.campaigns.new(
      title: title,
      description: description,
      message: message,
      inbox_id: inbox_id,
      enabled: enabled.nil? || enabled,
      trigger_rules: parsed_object(trigger_rules_json) || {},
      audience: parsed_array(audience_json) || []
    )
    authorize!(campaign, :create?)

    campaign.save!
    "Campaign created successfully.\n#{format_campaign(campaign)}"
  rescue UnauthorizedError
    handle_unauthorized
  rescue ActiveRecord::RecordInvalid => e
    handle_record_invalid(e.record)
  end

  private

  def parsed_object(json_string)
    return nil if json_string.blank?

    parsed = JSON.parse(json_string)
    parsed if parsed.is_a?(Hash)
  rescue JSON::ParserError
    nil
  end

  def parsed_array(json_string)
    return nil if json_string.blank?

    parsed = JSON.parse(json_string)
    parsed if parsed.is_a?(Array)
  rescue JSON::ParserError
    nil
  end
end
