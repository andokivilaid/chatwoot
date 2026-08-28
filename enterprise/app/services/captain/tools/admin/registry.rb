class Captain::Tools::Admin::Registry
  LEGACY_READ_TOOLS = [
    Captain::Tools::Admin::GetMacroService,
    Captain::Tools::Admin::GetAutomationRuleService
  ].freeze

  LEGACY_WRITE_TOOLS = [
    Captain::Tools::Admin::UpdateInboxSettingsService,
    Captain::Tools::Admin::UpdateInboxWorkingHoursService,
    Captain::Tools::Admin::CreateInboxService,
    Captain::Tools::Admin::DeleteInboxService,
    Captain::Tools::Admin::CreateAutomationRuleService,
    Captain::Tools::Admin::UpdateAutomationRuleService,
    Captain::Tools::Admin::DeleteAutomationRuleService,
    Captain::Tools::Admin::CreateMacroService,
    Captain::Tools::Admin::UpdateMacroService,
    Captain::Tools::Admin::DeleteMacroService
  ].freeze

  def self.build(assistant, user:, copilot_thread: nil)
    catalog_tools(assistant, user: user, copilot_thread: copilot_thread) +
      legacy_tools(assistant, user: user, copilot_thread: copilot_thread)
  end

  def self.catalog_tools(assistant, user:, copilot_thread: nil)
    Captain::Capabilities::Catalog.captain_capabilities_for(
      exposure: :copilot,
      account: assistant.account,
      user: user
    ).map do |capability|
      Captain::Tools::CapabilityTool.build(
        assistant,
        capability: capability,
        user: user,
        copilot_thread: copilot_thread
      )
    end.select(&:active?)
  end

  def self.legacy_tools(assistant, user:, copilot_thread: nil)
    (LEGACY_READ_TOOLS + LEGACY_WRITE_TOOLS).map do |tool_class|
      tool_class.new(assistant, user: user, copilot_thread: copilot_thread)
    end.select(&:active?)
  end

  # Kept for CopilotPendingAdminAction executor compatibility with legacy write tools.
  WRITE_TOOLS = LEGACY_WRITE_TOOLS.freeze
end
