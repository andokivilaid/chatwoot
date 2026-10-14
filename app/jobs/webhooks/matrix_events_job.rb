class Webhooks::MatrixEventsJob < ApplicationJob
  queue_as :default

  def perform(channel_id, events)
    channel = Channel::Matrix.find(channel_id)
    return unless channel.account.active?

    events.each do |event|
      Matrix::IncomingEventService.new(inbox: channel.inbox, event: event.with_indifferent_access).perform
    end
  end
end
