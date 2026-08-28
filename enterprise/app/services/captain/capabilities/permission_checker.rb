class Captain::Capabilities::PermissionChecker
  CONVERSATION_PERMISSIONS = %w[
    conversation_manage
    conversation_unassigned_manage
    conversation_participating_manage
  ].freeze

  def self.permitted?(permission:, account:, user:)
    new(permission: permission, account: account, user: user).permitted?
  end

  def initialize(permission:, account:, user:)
    @permission = permission.to_s
    @account = account
    @user = user
    @account_user = AccountUser.find_by(account_id: account.id, user_id: user&.id)
  end

  def permitted?
    return false if @user.blank? || @account_user.blank?

    case @permission
    when 'administrator'
      @account_user.administrator?
    when 'agent'
      @account_user.administrator? || @account_user.agent?
    when 'conversation_access'
      conversation_access?
    when 'contact_manage'
      custom_role_permission?('contact_manage') || default_agent_access?
    when 'knowledge_base_manage'
      custom_role_permission?('knowledge_base_manage') || default_agent_access?
    else
      custom_role_permission?(@permission) || default_agent_access?
    end
  end

  private

  def conversation_access?
    CONVERSATION_PERMISSIONS.any? { |permission| custom_role_permission?(permission) } || default_agent_access?
  end

  def custom_role_permission?(permission)
    return false if @account_user.custom_role.blank?

    @account_user.custom_role.permissions.include?(permission)
  end

  def default_agent_access?
    @account_user.administrator? || @account_user.agent?
  end
end
