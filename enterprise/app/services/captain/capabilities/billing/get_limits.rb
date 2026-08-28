class Captain::Capabilities::Billing::GetLimits < Captain::Capabilities::Base
  include BillingHelper

  def call
    authorize!(account, :limits?)
    return 'Billing limits are only available on Chatwoot Cloud' unless ChatwootApp.chatwoot_cloud?

    limits = cloud_limits
    "Billing limits:\n#{format_billing_limits(limits)}"
  rescue UnauthorizedError
    handle_unauthorized
  end

  private

  def cloud_limits
    return default_plan_limits if default_plan?(account)

    paid_plan_limits
  end

  def default_plan_limits
    {
      'conversation' => {
        'allowed' => 500,
        'consumed' => conversations_this_month(account)
      },
      'non_web_inboxes' => {
        'allowed' => 0,
        'consumed' => non_web_inboxes(account)
      },
      'agents' => {
        'allowed' => 2,
        'consumed' => agents(account)
      }
    }
  end

  def paid_plan_limits
    {
      'conversation' => {},
      'non_web_inboxes' => {},
      'agents' => {
        'allowed' => account.usage_limits[:agents],
        'consumed' => agents(account)
      },
      'captain' => account.usage_limits[:captain]
    }
  end
end
