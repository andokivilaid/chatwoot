class Captain::Capabilities::Articles::Get < Captain::Capabilities::Base
  def call(article_id:)
    article = Article.find_by(id: article_id, account_id: account.id)
    return 'Article not found' if article.nil?

    authorize!(article, :show?)

    article.to_llm_text
  rescue UnauthorizedError
    handle_unauthorized
  end
end
