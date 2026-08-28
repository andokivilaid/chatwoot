class Captain::Capabilities::Labels::Delete < Captain::Capabilities::Base
  def call(label_id:)
    label = account.labels.find_by(id: label_id)
    return 'Label not found' if label.blank?

    authorize!(label, :destroy?)

    label_title = label.title
    label.destroy!
    Labels::RemoveAssociationsJob.perform_later(
      label_title: label_title,
      account_id: account.id,
      label_deleted_at: Time.current
    )

    "Label '#{label_title}' deleted successfully."
  rescue UnauthorizedError
    handle_unauthorized
  end
end
