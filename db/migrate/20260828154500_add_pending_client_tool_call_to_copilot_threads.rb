class AddPendingClientToolCallToCopilotThreads < ActiveRecord::Migration[7.2]
  def change
    add_column :copilot_threads, :pending_client_tool_call, :jsonb
  end
end
