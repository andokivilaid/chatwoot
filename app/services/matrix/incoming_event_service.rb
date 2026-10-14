# Turns a Matrix `m.room.message` event from a bridged room into a Chatwoot message.
# Each bridged room is one contact + conversation; messages sent by the connected
# Matrix user from elsewhere (e.g. their phone) are recorded as outgoing.
class Matrix::IncomingEventService
  include ::FileTypeHelper
  pattr_initialize [:inbox!, :event!]

  MEDIA_MSGTYPES = %w[m.image m.video m.audio m.file].freeze
  TEXT_MSGTYPES = %w[m.text m.emote].freeze

  def perform
    return unless message_event? && from_bridged_contact?
    return if inbox.messages.exists?(source_id: event[:event_id])

    set_contact
    set_conversation
    build_message
    attach_media if media?
    @message.save!
  end

  private

  delegate :channel, to: :inbox

  def message_event?
    event[:type] == 'm.room.message' &&
      (TEXT_MSGTYPES + MEDIA_MSGTYPES).include?(content[:msgtype]) &&
      content.dig(:'m.relates_to', :rel_type) != 'm.replace' &&
      content[:'com.chatwoot.message_id'].blank? &&
      # Bridges backfill history when a chat is first bridged; only mirror what happens after connecting.
      Time.zone.at(event[:origin_server_ts] / 1000.0) >= channel.created_at
  end

  def from_bridged_contact?
    room_info.present? && room_info['bridged'] && sender != room_info['bridgebot']
  end

  def build_message
    @message = @conversation.messages.build(
      content: message_content,
      account_id: inbox.account_id,
      inbox_id: inbox.id,
      message_type: outgoing? ? :outgoing : :incoming,
      sender: outgoing? ? nil : @contact,
      source_id: event[:event_id]
    )
  end

  def content
    event[:content] || {}
  end

  def sender
    event[:sender]
  end

  def room_id
    event[:room_id]
  end

  def room_info
    @room_info ||= channel.room_info(room_id)
  end

  def outgoing?
    sender == channel.user_id
  end

  def media?
    MEDIA_MSGTYPES.include?(content[:msgtype])
  end

  def set_contact
    @contact_inbox = ::ContactInboxWithContactBuilder.new(
      source_id: room_id,
      inbox: inbox,
      contact_attributes: {
        name: contact_name,
        additional_attributes: { matrix_room_id: room_id, matrix_network: room_info['network'] }
      }
    ).perform
    @contact = @contact_inbox.contact
  end

  def contact_name
    other_members = room_info['members'].except(channel.user_id, room_info['bridgebot'])
    room_info['name'].presence || other_members.values.compact.first || room_id
  end

  def set_conversation
    @conversation = existing_conversation || create_conversation
  end

  # Replies sent from the user's phone attach to the latest conversation instead of opening a new one.
  def existing_conversation
    conversations = @contact_inbox.conversations
    return conversations.last if inbox.lock_to_single_conversation || outgoing?

    conversations.where.not(status: :resolved).last
  end

  def create_conversation
    conversation = ::Conversation.create!(
      account_id: inbox.account_id,
      inbox_id: inbox.id,
      contact_id: @contact.id,
      contact_inbox_id: @contact_inbox.id,
      additional_attributes: { matrix_room_id: room_id, matrix_network: room_info['network'] }
    )
    label_with_network(conversation)
    conversation
  end

  def label_with_network(conversation)
    network = room_info['network']
    return if network.blank?

    inbox.account.labels.find_or_create_by!(title: network) { |label| label.description = room_info['network_name'] }
    conversation.add_labels([network])
  end

  def message_content
    body = media? ? caption : content[:body]
    return body if outgoing? || room_info['direct'] || body.blank?

    "#{sender_name}: #{body}"
  end

  # For media, `body` is the caption only when a separate `filename` is given.
  def caption
    content[:body] if content[:filename].present? && content[:body] != content[:filename]
  end

  def sender_name
    room_info['members'][sender].presence || sender
  end

  def attach_media
    response = channel.download_media(content[:url])
    mimetype = content.dig(:info, :mimetype) || response.headers['content-type']
    @message.attachments.new(
      account_id: inbox.account_id,
      file_type: file_type(mimetype),
      file: {
        io: StringIO.new(response.body),
        filename: content[:filename].presence || content[:body].presence || 'attachment',
        content_type: mimetype
      }
    )
  end
end
