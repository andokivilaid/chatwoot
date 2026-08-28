module Captain::Capabilities::Formatters
  def format_label(label)
    <<~TEXT.strip
      Label ID: #{label.id}
      Title: #{label.title}
      Description: #{label.description}
      Color: #{label.color}
      Show on sidebar: #{label.show_on_sidebar}
    TEXT
  end

  def format_canned_response(canned_response)
    <<~TEXT.strip
      Canned Response ID: #{canned_response.id}
      Short code: #{canned_response.short_code}
      Content: #{canned_response.content}
    TEXT
  end

  def format_macro(macro)
    <<~TEXT.strip
      Macro ID: #{macro.id}
      Name: #{macro.name}
      Visibility: #{macro.visibility}
      Actions: #{macro.actions.to_json}
    TEXT
  end

  def format_inbox(inbox)
    <<~TEXT.strip
      Inbox ID: #{inbox.id}
      Name: #{inbox.name}
      Channel type: #{inbox.channel_type}
      Email: #{inbox.email_address}
      Timezone: #{inbox.timezone}
      Greeting enabled: #{inbox.greeting_enabled}
      Greeting message: #{inbox.greeting_message}
      Out of office message: #{inbox.out_of_office_message}
      Working hours enabled: #{inbox.working_hours_enabled}
      Working hours schedule: #{inbox.weekly_schedule.to_json}
      CSAT survey enabled: #{inbox.csat_survey_enabled}
      CSAT config: #{inbox.csat_config.to_json}
      Enable auto assignment: #{inbox.enable_auto_assignment}
      Enable email collect: #{inbox.enable_email_collect}
      Allow messages after resolved: #{inbox.allow_messages_after_resolved}
      Lock to single conversation: #{inbox.lock_to_single_conversation}
      Business name: #{inbox.business_name}
    TEXT
  end

  def format_automation_rule(rule)
    <<~TEXT.strip
      Automation Rule ID: #{rule.id}
      Name: #{rule.name}
      Description: #{rule.description}
      Event: #{rule.event_name}
      Active: #{rule.active}
      Execution delay (minutes): #{rule.execution_delay}
      Conditions: #{rule.conditions.to_json}
      Actions: #{rule.actions.to_json}
    TEXT
  end

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

  def format_campaign(campaign)
    <<~TEXT.strip
      Campaign ID: #{campaign.display_id}
      Title: #{campaign.title}
      Description: #{campaign.description}
      Message: #{campaign.message}
      Inbox ID: #{campaign.inbox_id}
      Enabled: #{campaign.enabled}
      Campaign type: #{campaign.campaign_type}
      Campaign status: #{campaign.campaign_status}
      Trigger rules: #{campaign.trigger_rules.to_json}
      Audience: #{campaign.audience.to_json}
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
