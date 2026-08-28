class Captain::Tools::Admin::DeleteCannedResponseService < Captain::Tools::Admin::BaseTool
  def self.name
    'delete_canned_response'
  end

  description 'Delete a canned response'
  param :canned_response_id, type: :integer, desc: 'ID of the canned response to delete', required: true

  def execute(canned_response_id:)
    capability_service(Captain::Capabilities::CannedResponses::Delete, canned_response_id: canned_response_id)
  end
end
