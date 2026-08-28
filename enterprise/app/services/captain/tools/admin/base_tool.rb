class Captain::Tools::Admin::BaseTool < Captain::Tools::BaseTool
  include Captain::Capabilities::Formatters

  def initialize(assistant, user: nil, copilot_thread: nil)
    @copilot_thread = copilot_thread
    super(assistant, user: user)
  end

  def active?
    administrator?
  end

  private

  def administrator?
    return false if @user.blank?

    account_user = AccountUser.find_by(account_id: @assistant.account_id, user_id: @user.id)
    account_user&.administrator?
  end

  def account
    @assistant.account
  end

  def account_user
    @account_user ||= AccountUser.find_by(account_id: @assistant.account_id, user_id: @user.id)
  end

  def capability_service(service_class, **params)
    service_class.new(account: account, user: @user).call(**params)
  end

  def parse_json_array(json_string, param_name)
    return nil if json_string.blank?

    parsed = JSON.parse(json_string)
    return parsed if parsed.is_a?(Array)

    "Invalid #{param_name}: expected a JSON array"
  rescue JSON::ParserError
    "Invalid #{param_name}: could not parse JSON"
  end

  def parse_json_object(json_string, param_name)
    return nil if json_string.blank?

    parsed = JSON.parse(json_string)
    return parsed if parsed.is_a?(Hash)

    "Invalid #{param_name}: expected a JSON object"
  rescue JSON::ParserError
    "Invalid #{param_name}: could not parse JSON"
  end

  def json_parse_error?(value)
    value.is_a?(String) && value.start_with?('Invalid ')
  end

  def find_inbox(inbox_id)
    account.inboxes.find_by(id: inbox_id)
  end

  def delayed_automations_enabled?
    account.feature_enabled?('delayed_automations')
  end
end
