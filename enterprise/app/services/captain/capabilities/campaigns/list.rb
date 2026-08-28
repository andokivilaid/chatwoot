class Captain::Capabilities::Campaigns::List < Captain::Capabilities::Base
  def call(search: nil)
    authorize!(Campaign.new(account: account), :index?)

    campaigns = account.campaigns
    campaigns = campaigns.where('title ILIKE ?', "%#{search.downcase}%") if search.present?

    return 'No campaigns found' if campaigns.none?

    campaigns.limit(100).map { |campaign| format_campaign(campaign) }.join("\n---\n")
  rescue UnauthorizedError
    handle_unauthorized
  end
end
