class Captain::Capabilities::Campaigns::Update < Captain::Capabilities::Base
  def call(campaign_id:, title: nil, message: nil, enabled: nil, trigger_rules_json: nil, audience_json: nil)
    campaign = account.campaigns.find_by(display_id: campaign_id)
    return 'Campaign not found' if campaign.blank?

    authorize!(campaign, :update?)

    updates = {}.tap do |hash|
      hash[:title] = title unless title.nil?
      hash[:message] = message unless message.nil?
      hash[:enabled] = enabled unless enabled.nil?
    end

    updates[:trigger_rules] = parsed_object(trigger_rules_json) if trigger_rules_json.present?
    updates[:audience] = parsed_array(audience_json) if audience_json.present?

    return 'No changes were provided' if updates.blank?

    campaign.update!(updates)
    "Campaign updated successfully.\n#{format_campaign(campaign)}"
  rescue UnauthorizedError
    handle_unauthorized
  rescue ActiveRecord::RecordInvalid => e
    handle_record_invalid(e.record)
  end

  private

  def parsed_object(json_string)
    JSON.parse(json_string)
  rescue JSON::ParserError
    nil
  end

  def parsed_array(json_string)
    parsed = JSON.parse(json_string)
    parsed if parsed.is_a?(Array)
  rescue JSON::ParserError
    nil
  end
end
