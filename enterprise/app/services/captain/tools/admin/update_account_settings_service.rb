class Captain::Tools::Admin::UpdateAccountSettingsService < Captain::Tools::Admin::BaseTool
  def self.name
    'update_account_settings'
  end

  description 'Update account settings'
  param :name, type: :string, desc: 'Account name'
  param :locale, type: :string, desc: 'Account locale (e.g. en, fr)'
  param :domain, type: :string, desc: 'Account domain'
  param :support_email, type: :string, desc: 'Support email address'
  param :auto_resolve_after, type: :integer, desc: 'Minutes after which conversations auto-resolve'
  param :auto_resolve_message, type: :string, desc: 'Message sent when a conversation auto-resolves'
  param :auto_resolve_ignore_waiting, type: :boolean, desc: 'Whether to ignore waiting state for auto-resolve'
  param :audio_transcriptions, type: :boolean, desc: 'Enable audio transcriptions'
  param :auto_resolve_label, type: :string, desc: 'Label applied when a conversation auto-resolves'

  def execute(name: nil, locale: nil, domain: nil, support_email: nil, **settings)
    capability_service(
      Captain::Capabilities::AccountSettings::Update,
      name: name,
      locale: locale,
      domain: domain,
      support_email: support_email,
      **settings
    )
  end
end
