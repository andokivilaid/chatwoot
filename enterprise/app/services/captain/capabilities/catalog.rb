class Captain::Capabilities::Catalog
  class << self
    delegate :captain_capabilities, :find_captain_capability, :capability_description,
             :capability_handler_class, to: Concerns::CaptainCapabilitiesHelpers

    def resolve_capability_service(capability)
      capability_handler_class(capability)
    end

    def captain_capabilities_for(user:, account:, exposure: nil, route: nil)
      Concerns::CaptainCapabilitiesHelpers.captain_capabilities_for(
        user: user,
        account: account,
        exposure: exposure,
        route: route
      ).map do |capability|
        enrich_capability(capability)
      end
    end

    def enrich_capability(capability)
      capability.merge(
        description: capability_description(capability),
        copilot_execution: capability[:copilot_execution].presence || 'server',
        requires_page_context: capability[:requires_page_context] == true
      )
    end
  end
end
