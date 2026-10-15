# What Chatwoot needs to know about a Matrix room, derived from its state events.
# Only rooms carrying an `m.bridge` state event (set by mautrix and other bridges) are bridged.
class Matrix::RoomInfo
  def self.from_state(state_events, own_user_id)
    new(state_events).to_h(own_user_id)
  end

  def initialize(state_events)
    @state_events = state_events
  end

  def to_h(own_user_id)
    bridge = state_content('m.bridge')
    return { 'bridged' => false } if bridge.blank?

    others = joined_members.keys - [own_user_id, bridge['bridgebot']]
    {
      'bridged' => true,
      'bridgebot' => bridge['bridgebot'],
      'network' => bridge.dig('protocol', 'id'),
      'network_name' => bridge.dig('protocol', 'displayname'),
      'name' => state_content('m.room.name')['name'],
      'direct' => others.size <= 1,
      'members' => joined_members
    }
  end

  private

  def state_content(type)
    @state_events.find { |event| event['type'] == type }&.dig('content') || {}
  end

  def joined_members
    @joined_members ||= @state_events.select { |event| event['type'] == 'm.room.member' && event.dig('content', 'membership') == 'join' }
                                     .to_h { |event| [event['state_key'], event.dig('content', 'displayname')] }
  end
end
