class Captain::Tools::Admin::CreateLabelService < Captain::Tools::Admin::BaseTool
  def self.name
    'create_label'
  end

  description 'Create a new label'
  param :title, type: :string, desc: 'Label title', required: true
  param :description, type: :string, desc: 'Label description'
  param :color, type: :string, desc: 'Label color hex code (e.g. #1f93ff)'
  param :show_on_sidebar, type: :boolean, desc: 'Whether to show the label on the sidebar'

  def execute(title:, description: nil, color: nil, show_on_sidebar: nil)
    capability_service(
      Captain::Capabilities::Labels::Create,
      title: title,
      description: description,
      color: color,
      show_on_sidebar: show_on_sidebar
    )
  end
end
