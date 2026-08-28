class Captain::Capabilities::Contacts::Search < Captain::Capabilities::Base
  def call(email: nil, phone_number: nil, name: nil)
    authorize!(Contact, :index?)

    contacts = Contact.where(account_id: account.id)
    contacts = contacts.where(email: email) if email.present?
    contacts = contacts.where(phone_number: phone_number) if phone_number.present?
    contacts = contacts.where('LOWER(name) ILIKE ?', "%#{name.downcase}%") if name.present?

    return 'No contacts found' unless contacts.exists?

    contacts.limit(100).map(&:to_llm_text).join("\n---\n")
  rescue UnauthorizedError
    handle_unauthorized
  end
end
