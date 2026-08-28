class Captain::Tools::Copilot::GetContactService < Captain::Tools::BaseTool
  def self.name
    'get_contact'
  end
  description 'Get details of a contact including their profile information'
  param :contact_id, type: :number, desc: 'The ID of the contact to retrieve', required: true

  def execute(contact_id:)
    capability_service(Captain::Capabilities::Contacts::Get, contact_id: contact_id)
  end

  def active?
    user_has_permission('contact_manage')
  end

  private

  def capability_service(service_class, **params)
    service_class.new(account: @assistant.account, user: @user).call(**params)
  end
end
