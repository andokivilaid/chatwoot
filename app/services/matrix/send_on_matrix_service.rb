class Matrix::SendOnMatrixService < Base::SendOnChannelService
  MSGTYPES = { 'image' => 'm.image', 'video' => 'm.video', 'audio' => 'm.audio' }.freeze

  private

  def channel_class
    Channel::Matrix
  end

  def perform_reply
    event_id = send_event(msgtype: 'm.text', body: message.outgoing_content) if message.outgoing_content.present?
    message.attachments.each do |attachment|
      break if message.failed?

      event_id = send_attachment(attachment)
    end
    message.update!(source_id: event_id) if event_id.present?
  end

  def send_attachment(attachment)
    blob = attachment.file
    mxc_url = blob.open { |file| channel.upload_media(file, filename: blob.filename.to_s, content_type: blob.content_type) }
    send_event(
      msgtype: MSGTYPES.fetch(attachment.file_type, 'm.file'),
      body: blob.filename.to_s,
      url: mxc_url,
      info: { mimetype: blob.content_type, size: blob.byte_size }
    )
  end

  # The `com.chatwoot.message_id` marker lets the incoming side skip the echo of this event.
  def send_event(content)
    response = channel.client_request(
      :put,
      "#{channel.room_path(contact_inbox.source_id)}/send/m.room.message/chatwoot-#{message.id}-#{SecureRandom.hex(4)}",
      body: content.merge('com.chatwoot.message_id': message.id)
    )
    return response.parsed_response['event_id'] if response.success?

    message.update!(status: :failed, external_error: "#{response.code}: #{response.parsed_response.try(:dig, 'error') || response.body}")
    nil
  end
end
