class Captain::Capabilities::Macros::Get < Captain::Capabilities::Base
  def call(macro_id:)
    macro = account.macros.find_by(id: macro_id)
    return 'Macro not found' if macro.blank?

    authorize!(macro, :show?)
    format_macro(macro)
  rescue UnauthorizedError
    handle_unauthorized
  end
end
