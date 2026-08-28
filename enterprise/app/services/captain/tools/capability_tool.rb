class Captain::Tools::CapabilityTool < Captain::Tools::BaseTool
  PARAM_TYPE_MAP = {
    'integer' => :integer,
    'number' => :number,
    'boolean' => :boolean,
    'string' => :string
  }.freeze

  class << self
    def build(assistant, capability:, user: nil, copilot_thread: nil)
      capability_class(capability).new(
        assistant,
        capability: capability,
        user: user,
        copilot_thread: copilot_thread
      )
    end

    def capability_class(capability)
      capability_id = capability['id']
      @capability_classes ||= {}
      @capability_classes[capability_id] ||= define_capability_class(capability)
    end

    private

    def define_capability_class(capability)
      capability_definition = capability.with_indifferent_access
      description_text = Concerns::CaptainCapabilitiesHelpers.capability_description(capability_definition)

      Class.new(self) do
        define_singleton_method(:capability_definition) { capability_definition }

        description description_text

        capability_definition.fetch(:params, {}).each do |param_name, param_config|
          param param_name.to_sym,
                type: Captain::Tools::CapabilityTool::PARAM_TYPE_MAP.fetch(param_config[:type].to_s, :string),
                desc: param_config[:description],
                required: param_config.fetch(:required, false)
        end
      end
    end
  end

  def initialize(assistant, capability:, user: nil, copilot_thread: nil)
    @capability = capability.with_indifferent_access
    @copilot_thread = copilot_thread
    super(assistant, user: user)
  end

  def name
    @capability[:id]
  end

  def execute(**params)
    return execute_client_tool(params) if client_execution?

    service_class = Captain::Capabilities::Catalog.resolve_capability_service(@capability)
    return "Capability handler not found: #{@capability[:id]}" if service_class.blank?

    service_class.new(account: @assistant.account, user: @user).call(**params)
  rescue Captain::Capabilities::Base::UnauthorizedError => e
    e.message
  end

  def active?
    Captain::Capabilities::PermissionChecker.permitted?(
      permission: @capability[:permission],
      account: @assistant.account,
      user: @user
    )
  end

  private

  def client_execution?
    @capability[:copilot_execution].to_s == 'client'
  end

  def execute_client_tool(params)
    return 'Copilot thread is required for client-side tool execution' if @copilot_thread.blank?

    payload = {
      name: @capability[:id],
      arguments: params
    }

    @copilot_thread.update!(
      pending_client_tool_call: {
        tool_name: @capability[:id],
        arguments: params,
        requested_at: Time.current.iso8601
      }
    )

    halt({ client_tool_request: payload }.to_json)
  end
end
