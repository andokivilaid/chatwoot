class Captain::Capabilities::Labels::Create < Captain::Capabilities::Base
  def call(title:, description: nil, color: nil, show_on_sidebar: nil)
    label = account.labels.new(title: title, description: description, color: color, show_on_sidebar: show_on_sidebar)
    authorize!(label, :create?)

    label.save!
    "Label created successfully.\n#{format_label(label)}"
  rescue UnauthorizedError
    handle_unauthorized
  rescue ActiveRecord::RecordInvalid => e
    handle_record_invalid(e.record)
  end
end
