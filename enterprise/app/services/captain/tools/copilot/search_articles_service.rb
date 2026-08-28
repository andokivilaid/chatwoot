class Captain::Tools::Copilot::SearchArticlesService < Captain::Tools::BaseTool
  def self.name
    'search_articles'
  end
  description 'Search articles based on parameters'
  param :query, desc: 'Search articles by title or content (partial match)', required: false
  param :category_id, type: :number, desc: 'Filter articles by category ID', required: false
  param :status, type: :string, desc: 'Filter articles by status - MUST BE ONE OF: draft, published, archived', required: false

  def execute(query: nil, category_id: nil, status: nil)
    capability_service(
      Captain::Capabilities::Articles::Search,
      query: query,
      category_id: category_id,
      status: status
    )
  end

  def active?
    user_has_permission('knowledge_base_manage')
  end

  private

  def capability_service(service_class, **params)
    service_class.new(account: @assistant.account, user: @user).call(**params)
  end
end
