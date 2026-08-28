class Captain::Tools::Admin::CreateCannedResponseService < Captain::Tools::Admin::BaseTool
  def self.name
    'create_canned_response'
  end

  description 'Create a new canned response'
  param :short_code, type: :string, desc: 'Short code used to insert the canned response', required: true
  param :content, type: :string, desc: 'Canned response content', required: true

  def execute(short_code:, content:)
    capability_service(Captain::Capabilities::CannedResponses::Create, short_code: short_code, content: content)
  end
end
