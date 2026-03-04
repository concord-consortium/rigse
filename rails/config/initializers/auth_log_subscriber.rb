module AuthLogSubscriber
  def process_action(event)
    super
    payload = event.payload
    additions = []
    additions << "user=#{payload[:user_id]}" if payload[:user_id]
    additions << "auth=#{payload[:auth_strategy]}" if payload[:auth_strategy]
    additions << "client=#{payload[:auth_client]}" if payload[:auth_client]
    info("  Auth: #{additions.join(' ')}") if additions.any?
  end
end

require 'action_controller/log_subscriber'
ActionController::LogSubscriber.prepend(AuthLogSubscriber)
