class Captain::Capabilities::Contacts::Get < Captain::Capabilities::Base
  def call(contact_id:)
    authorize!(Contact, :show?)

    contact = Contact.find_by(id: contact_id, account_id: account.id)
    return 'Contact not found' if contact.nil?

    contact.to_llm_text
  rescue UnauthorizedError
    handle_unauthorized
  end
end
