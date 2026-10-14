# Matrix application service endpoints. The homeserver appends `/_matrix/app/v1/...`
# to the registration URL (`/webhooks/matrix/:channel_id`) and authenticates with the hs_token.
class Webhooks::MatrixController < ActionController::API
  before_action :authenticate_homeserver

  def transactions
    Webhooks::MatrixEventsJob.perform_later(@channel.id, JSON.parse(request.raw_post).fetch('events', []))
    render json: {}
  end

  def ping
    render json: {}
  end

  # User and room alias queries: Chatwoot doesn't provision users or rooms.
  def not_found
    render json: { errcode: 'M_NOT_FOUND' }, status: :not_found
  end

  private

  def authenticate_homeserver
    @channel = Channel::Matrix.find_by(id: params[:channel_id])
    token = request.authorization.to_s.delete_prefix('Bearer ').presence || params[:access_token]
    return if @channel&.valid_hs_token?(token)

    render json: { errcode: 'M_FORBIDDEN' }, status: :forbidden
  end
end
