class Captain::Tools::Admin::Executor
  def self.execute!(pending_action:, assistant:, user:)
    capability_id = capability_id_for(pending_action.tool_name)
    capability = Captain::Capabilities::Catalog.find_captain_capability(capability_id)
    raise ArgumentError, "Unknown admin tool: #{pending_action.tool_name}" if capability.blank?

    service_class = Captain::Capabilities::Catalog.resolve_capability_service(capability)
    raise ArgumentError, "Capability handler not found: #{capability_id}" if service_class.blank?

    params = pending_action.action_params.symbolize_keys
    service_class.new(account: assistant.account, user: user).call(**params)
  end

  def self.capability_id_for(tool_name)
    tool_class = Captain::Tools::Admin::Registry::WRITE_TOOLS.find { |klass| klass.name == tool_name }
    tool_class&.name || tool_name
  end
end
