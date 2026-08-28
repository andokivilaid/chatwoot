class Captain::Capabilities::Articles::Search < Captain::Capabilities::Base
  def call(query: nil, category_id: nil, status: nil)
    authorize!(Article, :index?)

    articles = Article.where(account_id: account.id)
    articles = articles.where('title ILIKE :query OR content ILIKE :query', query: "%#{query}%") if query.present?
    articles = articles.where(category_id: category_id) if category_id.present?
    articles = articles.where(status: status) if status.present?

    return 'No articles found' unless articles.exists?

    total_count = articles.count
    articles = articles.limit(100)

    <<~RESPONSE
      #{total_count > 100 ? "Found #{total_count} articles (showing first 100)" : "Total number of articles: #{total_count}"}
      #{articles.map(&:to_llm_text).join("\n---\n")}
    RESPONSE
  rescue UnauthorizedError
    handle_unauthorized
  end
end
