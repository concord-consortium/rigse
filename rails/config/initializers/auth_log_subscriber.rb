module AuthLogSubscriber
  def process_action(event)
    req = event.payload[:request]
    return super unless req

    additions = []
    additions << "user=#{req.env['warden'].user&.id}" if req.env['warden']&.user
    additions << "auth=#{req.env['portal.auth_strategy']}" if req.env['portal.auth_strategy']
    additions << "client=#{req.env['portal.auth_client']}" if req.env['portal.auth_client']
    additions << "#{req.request_method} #{req.path}" if additions.any?
    info("  Auth: #{additions.join(' ')}") if additions.any?
    super
  end
end

require 'action_controller/log_subscriber'
ActionController::LogSubscriber.prepend(AuthLogSubscriber)
