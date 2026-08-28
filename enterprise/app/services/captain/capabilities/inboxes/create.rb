class Captain::Capabilities::Inboxes::Create < Captain::Capabilities::Base
  SUPPORTED_CHANNEL_TYPES = %w[api web_widget].freeze

  def call(name:, channel_type:, website_url: nil, webhook_url: nil, widget_color: nil)
    authorize!(Inbox.new(account: account), :create?)

    unless SUPPORTED_CHANNEL_TYPES.include?(channel_type)
      return "Unsupported channel type: #{channel_type}. Supported types: #{SUPPORTED_CHANNEL_TYPES.join(', ')}"
    end

    inbox = nil
    ActiveRecord::Base.transaction do
      channel = create_channel(channel_type, website_url: website_url, webhook_url: webhook_url, widget_color: widget_color)
      return channel if channel.is_a?(String)

      inbox = account.inboxes.create!(name: name, channel: channel)
    end

    "Inbox created successfully.\n#{format_inbox(inbox)}"
  rescue UnauthorizedError
    handle_unauthorized
  rescue ActiveRecord::RecordInvalid => e
    handle_record_invalid(e.record)
  end

  private

  def create_channel(channel_type, website_url:, webhook_url:, widget_color:)
    case channel_type
    when 'api'
      account.api_channels.create!(webhook_url: webhook_url)
    when 'web_widget'
      return 'website_url is required for web_widget inboxes' if website_url.blank?

      account.web_widgets.create!(
        website_url: website_url,
        widget_color: widget_color.presence || '#1f93ff'
      )
    end
  end
end
