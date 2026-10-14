class Captain::Capabilities::Articles::Search < Captain::Capabilities::Base
  def call(query: nil, category_id: nil, status: nil)
    authorize!(Article, :index?)

    articles = Article.where(account_id: account.id).where({ category_id: category_id, status: status }.compact_blank)
    articles = articles.where('title ILIKE :query OR content ILIKE :query', query: "%#{query}%") if query.present?

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
