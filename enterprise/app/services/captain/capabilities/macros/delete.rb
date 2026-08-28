class Captain::Capabilities::Macros::Delete < Captain::Capabilities::Base
  def call(macro_id:)
    macro = account.macros.find_by(id: macro_id)
    return 'Macro not found' if macro.blank?

    authorize!(macro, :destroy?)
    macro.destroy!

    "Macro ##{macro_id} deleted successfully"
  rescue UnauthorizedError
    handle_unauthorized
  end
end
