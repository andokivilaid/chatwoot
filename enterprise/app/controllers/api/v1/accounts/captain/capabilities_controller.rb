class Api::V1::Accounts::Captain::CapabilitiesController < Api::V1::Accounts::BaseController
  def index
    @capabilities = Captain::Capabilities::Catalog.captain_capabilities_for(
      exposure: exposure_param,
      account: Current.account,
      user: Current.user,
      route: params[:route]
    )
  end

  private

  def exposure_param
    params[:exposure].presence || 'webmcp'
  end
end
