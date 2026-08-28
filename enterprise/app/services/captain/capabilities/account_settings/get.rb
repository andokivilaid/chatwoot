class Captain::Capabilities::AccountSettings::Get < Captain::Capabilities::Base
  def call
    authorize!(account, :show?)

    format_account_summary(account)
  rescue UnauthorizedError
    handle_unauthorized
  end
end
