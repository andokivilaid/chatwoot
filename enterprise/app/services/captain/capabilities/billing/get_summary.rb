class Captain::Capabilities::Billing::GetSummary < Captain::Capabilities::Base
  include BillingHelper

  def call
    authorize!(account, :subscription?)

    format_billing_summary(account)
  rescue UnauthorizedError
    handle_unauthorized
  end
end
