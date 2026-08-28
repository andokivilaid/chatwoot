class Captain::Copilot::ToolResultsJob < ApplicationJob
  queue_as :default

  def perform(assistant:, user_id:, copilot_thread_id:, conversation_id:, tool_results:)
    service = Captain::Copilot::ChatService.new(
      assistant,
      user_id: user_id,
      copilot_thread_id: copilot_thread_id,
      conversation_id: conversation_id
    )

    service.continue_with_tool_results(normalize_tool_results(tool_results))
  end

  private

  def normalize_tool_results(tool_results)
    tool_results.map do |tool_result|
      {
        name: tool_result[:name] || tool_result['name'],
        result: tool_result[:result] || tool_result['result'] || tool_result[:error] || tool_result['error']
      }
    end
  end
end
