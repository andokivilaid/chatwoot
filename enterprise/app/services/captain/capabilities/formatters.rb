module Captain::Capabilities::Formatters
  include Captain::Capabilities::AccountFormatters

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
end
