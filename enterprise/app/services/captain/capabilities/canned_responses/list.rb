class Captain::Capabilities::CannedResponses::List < Captain::Capabilities::Base
  def call(search: nil)
    return handle_unauthorized unless account_user&.administrator?

    canned_responses = account.canned_responses
    if search.present?
      sanitized_search = search.delete("\0")
      canned_responses = canned_responses.where(
        'short_code ILIKE :search OR content ILIKE :search',
        search: "%#{sanitized_search}%"
      )
    end

    return 'No canned responses found' if canned_responses.none?

    canned_responses.limit(100).map { |canned_response| format_canned_response(canned_response) }.join("\n---\n")
  end
end
