class Captain::Tools::Admin::GetAccountSettingsService < Captain::Tools::Admin::BaseTool
  def self.name
    'get_account_settings'
  end

  description 'Get account settings including name, locale, domain, support email, and configuration options'

  def execute
    capability_service(Captain::Capabilities::AccountSettings::Get)
  end
end
