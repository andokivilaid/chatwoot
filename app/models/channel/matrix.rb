# == Schema Information
#
# Table name: channel_matrix
#
#  id               :bigint           not null, primary key
#  as_token         :string           not null
#  homeserver_url   :string           not null
#  hs_token         :string           not null
#  sender_localpart :string           not null
#  user_id          :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  account_id       :integer          not null
#
# Indexes
#
#  index_channel_matrix_on_account_id_and_user_id  (account_id,user_id) UNIQUE
#

# Connects Chatwoot to a Matrix homeserver as an application service that acts
# on behalf of a single Matrix user. Rooms created by bridges (mautrix etc.) that
# the user is in become Chatwoot conversations; replies are sent as that user.
class Channel::Matrix < ApplicationRecord
  include Channelable

  self.table_name = 'channel_matrix'
  EDITABLE_ATTRS = [:homeserver_url, :user_id].freeze
  ROOM_INFO_TTL = 1.hour

  encrypts :as_token, :hs_token if Chatwoot.encryption_configured?

  validates :homeserver_url, presence: true, format: { with: %r{\Ahttps?://\S+\z} }
  validates :user_id, presence: true, uniqueness: { scope: :account_id }, format: { with: /\A@[^:\s]+:\S+\z/ }

  before_validation :generate_appservice_credentials, on: :create

  def name
    'Matrix'
  end

  def appservice_url
    "#{ENV.fetch('FRONTEND_URL', nil)}/webhooks/matrix/#{id}"
  end

  # Paste into the homeserver admin room (Tuwunel/conduwuit) to register Chatwoot as an appservice.
  def registration_command
    "!admin appservices register\n```\n#{registration_yaml}```"
  end

  def registration_yaml
    {
      'id' => "chatwoot-#{id}",
      'url' => appservice_url,
      'as_token' => as_token,
      'hs_token' => hs_token,
      'sender_localpart' => sender_localpart,
      'rate_limited' => false,
      'namespaces' => {
        'users' => [{ 'regex' => "^#{Regexp.escape(user_id)}$", 'exclusive' => false }],
        'rooms' => [],
        'aliases' => []
      }
    }.to_yaml.delete_prefix("---\n")
  end

  def valid_hs_token?(token)
    token.present? && ActiveSupport::SecurityUtils.secure_compare(token, hs_token)
  end

  def client_request(method, path, body: nil, query: {})
    HTTParty.send(
      method,
      "#{homeserver_url.chomp('/')}#{path}",
      query: query.merge(user_id: user_id),
      headers: { 'Authorization' => "Bearer #{as_token}", 'Content-Type' => 'application/json' },
      body: body.is_a?(Hash) ? body.to_json : body
    )
  end

  def room_path(room_id)
    "/_matrix/client/v3/rooms/#{ERB::Util.url_encode(room_id)}"
  end

  # Returns nil when the room state can't be read yet (e.g. invite not accepted), so it isn't cached.
  def room_info(room_id)
    Rails.cache.fetch("matrix_channel:#{id}:room:#{room_id}", expires_in: ROOM_INFO_TTL, skip_nil: true) do
      response = client_request(:get, "#{room_path(room_id)}/state")
      Matrix::RoomInfo.from_state(response.parsed_response, user_id) if response.success?
    end
  end

  def download_media(mxc_url)
    server_name, media_id = mxc_url.delete_prefix('mxc://').split('/', 2)
    response = client_request(:get, "/_matrix/client/v1/media/download/#{server_name}/#{media_id}")
    raise "Matrix media download failed (#{response.code}) for #{mxc_url}" unless response.success?

    response
  end

  def upload_media(io, filename:, content_type:)
    response = HTTParty.post(
      "#{homeserver_url.chomp('/')}/_matrix/media/v3/upload",
      query: { user_id: user_id, filename: filename },
      headers: { 'Authorization' => "Bearer #{as_token}", 'Content-Type' => content_type },
      body: io.read
    )
    raise "Matrix media upload failed (#{response.code}): #{response.body}" unless response.success?

    response.parsed_response['content_uri']
  end

  private

  def generate_appservice_credentials
    self.as_token ||= SecureRandom.hex(32)
    self.hs_token ||= SecureRandom.hex(32)
    self.sender_localpart ||= "chatwoot_#{SecureRandom.hex(8)}"
  end
end
