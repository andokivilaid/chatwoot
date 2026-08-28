class Captain::Capabilities::Labels::List < Captain::Capabilities::Base
  def call(search: nil)
    authorize!(Label, :index?)

    labels = account.labels
    labels = labels.where('title ILIKE ?', "%#{search.downcase}%") if search.present?

    return 'No labels found' if labels.none?

    labels.limit(100).map { |label| format_label(label) }.join("\n---\n")
  rescue UnauthorizedError
    handle_unauthorized
  end
end
