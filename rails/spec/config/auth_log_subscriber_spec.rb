require 'spec_helper'

RSpec.describe AuthLogSubscriber do
  let(:subscriber_class) do
    Class.new do
      def process_action(event); end
      prepend AuthLogSubscriber
      def logged; @logged ||= []; end
      def info(msg); logged << msg; end
    end
  end

  def event_with_env(env)
    req = double('request', env: env, request_method: 'POST', path: '/api/v1/students/add_to_class')
    double('event', payload: { request: req })
  end

  it 'emits minted_via and minted_for when the request carries the marker' do
    subscriber = subscriber_class.new
    subscriber.process_action(event_with_env(
      'portal.auth_strategy' => 'jwt_bearer_token',
      'portal.minted_via_oidc_client_id' => 7,
      'portal.minted_for' => 'ai4vs-flvs/random-assignment'
    ))
    line = subscriber.logged.join
    expect(line).to match(/minted_via=7/)
    expect(line).to match(%r{minted_for=ai4vs-flvs/random-assignment})
  end

  it 'omits the mint fields when the request carries no marker' do
    subscriber = subscriber_class.new
    subscriber.process_action(event_with_env('portal.auth_strategy' => 'api_session'))
    expect(subscriber.logged.join).not_to match(/minted_/)
  end
end
