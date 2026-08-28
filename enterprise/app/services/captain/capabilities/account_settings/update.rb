class Captain::Capabilities::AccountSettings::Update < Captain::Capabilities::Base
  ALLOWED_SETTINGS = %w[
    auto_resolve_after auto_resolve_message auto_resolve_ignore_waiting
    audio_transcriptions auto_resolve_label
  ].freeze

  def call(name: nil, locale: nil, domain: nil, support_email: nil, **settings)
    authorize!(account, :update?)

    account_record = account
    apply_account_attributes(account_record, name: name, locale: locale, domain: domain, support_email: support_email)
    settings_applied = apply_settings(account_record, settings)

    return 'No changes were provided' unless account_record.changed? || settings_applied

    account_record.save!
    "Account settings updated successfully.\n#{format_account_summary(account_record)}"
  rescue UnauthorizedError
    handle_unauthorized
  rescue ActiveRecord::RecordInvalid => e
    handle_record_invalid(e.record)
  end

  private

  def apply_account_attributes(account_record, name:, locale:, domain:, support_email:)
    account_record.name = name unless name.nil?
    account_record.locale = locale unless locale.nil?
    account_record.domain = domain unless domain.nil?
    account_record.support_email = support_email unless support_email.nil?
  end

  def apply_settings(account_record, settings)
    applied = false
    settings.each do |key, value|
      next unless ALLOWED_SETTINGS.include?(key.to_s)
      next if value.nil?

      account_record.public_send("#{key}=", value)
      applied = true
    end
    applied
  end
end
