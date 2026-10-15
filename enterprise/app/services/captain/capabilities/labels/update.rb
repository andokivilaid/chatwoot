class Captain::Capabilities::Labels::Update < Captain::Capabilities::Base
  def call(label_id:, title: nil, description: nil, color: nil, show_on_sidebar: nil)
    label = account.labels.find_by(id: label_id)
    return 'Label not found' if label.blank?

    authorize!(label, :update?)

    updates = { title: title, description: description, color: color, show_on_sidebar: show_on_sidebar }.compact
    return 'No changes were provided' if updates.blank?

    label.update!(updates)
    "Label updated successfully.\n#{format_label(label)}"
  rescue UnauthorizedError
    handle_unauthorized
  rescue ActiveRecord::RecordInvalid => e
    handle_record_invalid(e.record)
  end
end
