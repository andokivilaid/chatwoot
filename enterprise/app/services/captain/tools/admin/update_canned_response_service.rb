class Captain::Tools::Admin::UpdateCannedResponseService < Captain::Tools::Admin::BaseTool
  def self.name
    'update_canned_response'
  end

  description 'Update an existing canned response'
  param :canned_response_id, type: :integer, desc: 'ID of the canned response to update', required: true
  param :short_code, type: :string, desc: 'Short code used to insert the canned response'
  param :content, type: :string, desc: 'Canned response content'

  def execute(canned_response_id:, short_code: nil, content: nil)
    capability_service(
      Captain::Capabilities::CannedResponses::Update,
      canned_response_id: canned_response_id,
      short_code: short_code,
      content: content
    )
  end
end
