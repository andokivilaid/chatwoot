class Captain::Tools::Copilot::GetArticleService < Captain::Tools::BaseTool
  def self.name
    'get_article'
  end
  description 'Get details of an article including its content and metadata'
  param :article_id, type: :number, desc: 'The ID of the article to retrieve', required: true

  def execute(article_id:)
    capability_service(Captain::Capabilities::Articles::Get, article_id: article_id)
  end

  def active?
    user_has_permission('knowledge_base_manage')
  end

  private

  def capability_service(service_class, **params)
    service_class.new(account: @assistant.account, user: @user).call(**params)
  end
end
