class Captain::Tools::Admin::UpdateLabelService < Captain::Tools::Admin::BaseTool
  def self.name
    'update_label'
  end

  description 'Update an existing label'
  param :label_id, type: :integer, desc: 'ID of the label to update', required: true
  param :title, type: :string, desc: 'Label title'
  param :description, type: :string, desc: 'Label description'
  param :color, type: :string, desc: 'Label color hex code (e.g. #1f93ff)'
  param :show_on_sidebar, type: :boolean, desc: 'Whether to show the label on the sidebar'

  def execute(label_id:, title: nil, description: nil, color: nil, show_on_sidebar: nil)
    capability_service(
      Captain::Capabilities::Labels::Update,
      label_id: label_id,
      title: title,
      description: description,
      color: color,
      show_on_sidebar: show_on_sidebar
    )
  end
end
