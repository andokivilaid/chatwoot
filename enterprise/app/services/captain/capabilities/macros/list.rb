class Captain::Capabilities::Macros::List < Captain::Capabilities::Base
  def call(search: nil)
    authorize!(Macro, :index?)

    macros = account.macros
    macros = macros.where('name ILIKE ?', "%#{search}%") if search.present?

    return 'No macros found' if macros.none?

    macros.limit(100).map { |macro| format_macro(macro) }.join("\n---\n")
  rescue UnauthorizedError
    handle_unauthorized
  end
end
