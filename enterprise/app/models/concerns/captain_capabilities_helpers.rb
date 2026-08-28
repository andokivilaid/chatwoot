# Loads and filters Captain Copilot / WebMCP capabilities from config/copilot/capabilities.yml.
module Concerns::CaptainCapabilitiesHelpers
  CAPABILITIES_PATH = Rails.root.join('config/copilot/capabilities.yml').freeze

  module_function

  def captain_capabilities
    @captain_capabilities ||= load_captain_capabilities
  end

  def find_captain_capability(id)
    captain_capabilities.find { |capability| capability['id'] == id.to_s }
  end

  def captain_capabilities_for(user:, account:, exposure: nil, route: nil)
    return [] if user.blank?

    account_user = account.account_users.find_by(user_id: user.id)
    return [] if account_user.blank?

    captain_capabilities.filter do |capability|
      next false if exposure.present? && !capability['exposure']&.include?(exposure.to_s)
      next false if route.present? && !capability_route_matches?(capability['route'], route)
      next false unless capability_handler_resolvable?(capability)

      permitted_capability?(capability, account_user)
    end
  end

  def capability_description(capability)
    key = capability['description_key']
    return capability['title'] if key.blank?

    I18n.t(key, default: capability['title'])
  end

  def capability_handler_class(capability)
    handler_name = capability.dig('handler', 'service')
    return nil if handler_name.blank?

    handler_name.safe_constantize
  end

  def load_captain_capabilities
    YAML.load_file(CAPABILITIES_PATH).map(&:with_indifferent_access)
  rescue Errno::ENOENT
    Rails.logger.error 'Captain capabilities file not found'
    []
  end
  module_function :load_captain_capabilities

  def capability_handler_resolvable?(capability)
    capability_handler_class(capability).present?
  end
  module_function :capability_handler_resolvable?

  def capability_route_matches?(capability_route, current_route)
    return true if capability_route.blank?

    normalized_capability = capability_route.to_s.gsub(':accountId', '\d+')
    Regexp.new("\\A#{normalized_capability.gsub('/', '\\/')}\\z").match?(current_route.to_s)
  end
  module_function :capability_route_matches?

  def permitted_capability?(capability, account_user)
    Captain::Capabilities::PermissionChecker.permitted?(
      permission: capability['permission'],
      account: account_user.account,
      user: account_user.user
    )
  end
  module_function :permitted_capability?
end
