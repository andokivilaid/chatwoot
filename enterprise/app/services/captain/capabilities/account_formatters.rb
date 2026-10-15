module Captain::Capabilities::AccountFormatters
  def format_account_summary(account_record)
    <<~TEXT.strip
      Account ID: #{account_record.id}
      Name: #{account_record.name}
      Locale: #{account_record.locale}
      Domain: #{account_record.domain}
      Support email: #{account_record.support_email}
      Status: #{account_record.status}
      Settings: #{account_record.settings.to_json}
      Enabled features: #{account_record.enabled_features.join(', ')}
    TEXT
  end

  def format_integration_app(app, account:)
    <<~TEXT.strip
      Integration ID: #{app.id}
      Name: #{app.name}
      Description: #{app.description}
      Active: #{app.active?(account)}
      Enabled: #{app.enabled?(account)}
      Hook type: #{app.params[:hook_type]}
    TEXT
  end

  def format_integration_hook(hook)
    visible_settings = hook.app&.visible_properties&.each_with_object({}) do |key, settings|
      settings[key] = hook.settings[key] if hook.settings[key].present?
    end

    <<~TEXT.strip
      Hook ID: #{hook.id}
      App ID: #{hook.app_id}
      Inbox ID: #{hook.inbox_id}
      Status: #{hook.status}
      Hook type: #{hook.hook_type}
      Settings: #{visible_settings.to_json}
    TEXT
  end

  def format_webhook(webhook)
    <<~TEXT.strip
      Webhook ID: #{webhook.id}
      Name: #{webhook.name}
      URL: #{webhook.url}
      Inbox ID: #{webhook.inbox_id}
      Subscriptions: #{webhook.subscriptions.to_json}
    TEXT
  end

  def format_dashboard_app(dashboard_app)
    <<~TEXT.strip
      Dashboard App ID: #{dashboard_app.id}
      Title: #{dashboard_app.title}
      Content: #{dashboard_app.content.to_json}
    TEXT
  end

  def format_billing_summary(account_record)
    attributes = account_record.custom_attributes
    <<~TEXT.strip
      Plan name: #{attributes['plan_name']}
      Subscribed quantity: #{attributes['subscribed_quantity']}
      Billing currency: #{attributes['billing_currency']}
      Subscription renews on: #{attributes['subscription_ends_on']}
      Stripe customer configured: #{attributes['stripe_customer_id'].present?}
      Currency selection required: #{account_record.billing_currency_selection_required?}
    TEXT
  end

  def format_billing_limits(limits)
    limits.to_json
  end
end
