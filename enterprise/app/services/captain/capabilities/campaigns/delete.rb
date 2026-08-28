class Captain::Capabilities::Campaigns::Delete < Captain::Capabilities::Base
  def call(campaign_id:)
    campaign = account.campaigns.find_by(display_id: campaign_id)
    return 'Campaign not found' if campaign.blank?

    authorize!(campaign, :destroy?)
    campaign.destroy!

    "Campaign ##{campaign_id} deleted successfully"
  rescue UnauthorizedError
    handle_unauthorized
  end
end
