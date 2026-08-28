class Captain::Capabilities::CannedResponses::Create < Captain::Capabilities::Base
  def call(short_code:, content:)
    return handle_unauthorized unless account_user&.administrator?

    canned_response = account.canned_responses.create!(short_code: short_code, content: content)
    "Canned response created successfully.\n#{format_canned_response(canned_response)}"
  rescue ActiveRecord::RecordInvalid => e
    handle_record_invalid(e.record)
  end
end
