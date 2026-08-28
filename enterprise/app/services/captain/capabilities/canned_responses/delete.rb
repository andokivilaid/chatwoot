class Captain::Capabilities::CannedResponses::Delete < Captain::Capabilities::Base
  def call(canned_response_id:)
    return handle_unauthorized unless account_user&.administrator?

    canned_response = account.canned_responses.find_by(id: canned_response_id)
    return 'Canned response not found' if canned_response.blank?

    short_code = canned_response.short_code
    canned_response.destroy!
    "Canned response '#{short_code}' deleted successfully."
  end
end
