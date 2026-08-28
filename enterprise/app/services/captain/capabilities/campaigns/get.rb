class Captain::Capabilities::Campaigns::Get < Captain::Capabilities::Base
  def call(campaign_id:)
    campaign = account.campaigns.find_by(display_id: campaign_id)
    return 'Campaign not found' if campaign.blank?

    authorize!(campaign, :show?)
    format_campaign(campaign)
  rescue UnauthorizedError
    handle_unauthorized
  end
end
