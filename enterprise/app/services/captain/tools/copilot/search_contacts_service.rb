class Captain::Tools::Copilot::SearchContactsService < Captain::Tools::BaseTool
  def self.name
    'search_contacts'
  end

  description 'Search contacts based on query parameters'
  param :email, type: :string, desc: 'Filter contacts by email'
  param :phone_number, type: :string, desc: 'Filter contacts by phone number'
  param :name, type: :string, desc: 'Filter contacts by name (partial match)'

  def execute(email: nil, phone_number: nil, name: nil)
    capability_service(
      Captain::Capabilities::Contacts::Search,
      email: email,
      phone_number: phone_number,
      name: name
    )
  end

  def active?
    user_has_permission('contact_manage')
  end

  private

  def capability_service(service_class, **params)
    service_class.new(account: @assistant.account, user: @user).call(**params)
  end
end
