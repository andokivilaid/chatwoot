class Captain::Tools::Admin::CreateInboxService < Captain::Tools::Admin::BaseTool
  def self.name
    'create_inbox'
  end

  description 'Create a new inbox with an API or website channel.'
  param :name, type: :string, desc: 'Inbox name', required: true
  param :channel_type, type: :string, desc: 'Channel type: api or web_widget', required: true
  param :website_url, type: :string, desc: 'Website URL (required for web_widget)'
  param :webhook_url, type: :string, desc: 'Webhook URL (optional for api channel)'
  param :widget_color, type: :string, desc: 'Widget color for web_widget (e.g. #1f93ff)'

  def execute(name:, channel_type:, website_url: nil, webhook_url: nil, widget_color: nil)
    capability_service(
      Captain::Capabilities::Inboxes::Create,
      name: name,
      channel_type: channel_type,
      website_url: website_url,
      webhook_url: webhook_url,
      widget_color: widget_color
    )
  end
end
