class Captain::Capabilities::CannedResponses::Update < Captain::Capabilities::Base
  def call(canned_response_id:, short_code: nil, content: nil)
    return handle_unauthorized unless account_user&.administrator?

    canned_response = account.canned_responses.find_by(id: canned_response_id)
    return 'Canned response not found' if canned_response.blank?

    updates = { short_code: short_code, content: content }.compact
    return 'No changes were provided' if updates.blank?

    canned_response.update!(updates)
    "Canned response updated successfully.\n#{format_canned_response(canned_response)}"
  rescue ActiveRecord::RecordInvalid => e
    handle_record_invalid(e.record)
  end
end
