class Captain::Capabilities::Billing::GetTopupOptions < Captain::Capabilities::Base
  def call
    authorize!(account, :topup_options?)
    return 'Top-up options are only available on Chatwoot Cloud' unless ChatwootApp.chatwoot_cloud?

    service = Enterprise::Billing::TopupCheckoutService.new(account: account)
    options = service.available_options
    return 'No top-up options available' if options.blank?

    "Top-up options (currency: #{account.billing_currency}):\n#{options.to_json}"
  rescue UnauthorizedError
    handle_unauthorized
  end
end
