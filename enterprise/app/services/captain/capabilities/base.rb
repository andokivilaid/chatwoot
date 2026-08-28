class Captain::Capabilities::Base
  class UnauthorizedError < StandardError; end

  include Captain::Capabilities::Formatters

  def initialize(account:, user:)
    @account = account
    @user = user
  end

  def call(**params)
    raise NotImplementedError, "#{self.class.name} must implement #call"
  end

  private

  attr_reader :account, :user

  def account_user
    @account_user ||= AccountUser.find_by(account_id: account.id, user_id: user.id)
  end

  def user_context
    { user: user, account: account, account_user: account_user }
  end

  def authorize!(record, query)
    Pundit.authorize(user_context, record, query)
  rescue Pundit::NotAuthorizedError
    raise UnauthorizedError, 'You are not authorized to perform this action'
  end

  def unauthorized_message
    'You are not authorized to perform this action'
  end

  def handle_unauthorized
    unauthorized_message
  end

  def handle_record_invalid(record)
    "Failed to save: #{record.errors.full_messages.join(', ')}"
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
end
