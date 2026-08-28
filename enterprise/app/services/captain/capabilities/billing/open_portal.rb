class Captain::Capabilities::Billing::OpenPortal < Captain::Capabilities::Base
  def call
    authorize!(account, :checkout?)
    return 'Billing portal is only available on Chatwoot Cloud' unless ChatwootApp.chatwoot_cloud?

    customer_id = account.custom_attributes['stripe_customer_id']
    return 'Please subscribe to a plan before opening the billing portal' if customer_id.blank?

    session = Enterprise::Billing::CreateSessionService.new.create_session(customer_id)
    "Billing portal URL: #{session.url}"
  rescue UnauthorizedError
    handle_unauthorized
  rescue Stripe::StripeError => e
    "Failed to open billing portal: #{e.message}"
  end
end
