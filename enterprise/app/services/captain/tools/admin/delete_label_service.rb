class Captain::Tools::Admin::DeleteLabelService < Captain::Tools::Admin::BaseTool
  def self.name
    'delete_label'
  end

  description 'Delete a label'
  param :label_id, type: :integer, desc: 'ID of the label to delete', required: true

  def execute(label_id:)
    capability_service(Captain::Capabilities::Labels::Delete, label_id: label_id)
  end
end
