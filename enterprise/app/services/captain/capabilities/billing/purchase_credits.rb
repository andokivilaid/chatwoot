class Captain::Capabilities::Billing::PurchaseCredits < Captain::Capabilities::Base
  def call(credits:)
    authorize!(account, :topup_checkout?)
    return 'Credit purchases are only available on Chatwoot Cloud' unless ChatwootApp.chatwoot_cloud?

    service = Enterprise::Billing::TopupCheckoutService.new(account: account)
    result = service.create_checkout_session(credits: credits.to_i)
    account.reload

    captain_limits = account.usage_limits[:captain].to_json
    "Purchased #{result[:credits]} credits for #{result[:amount]} #{result[:currency].upcase}. " \
      "Updated Captain limits: #{captain_limits}"
  rescue UnauthorizedError
    handle_unauthorized
  rescue Enterprise::Billing::TopupCheckoutService::Error, Stripe::StripeError => e
    "Failed to purchase credits: #{e.message}"
  end
end
