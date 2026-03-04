require 'spec_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      render plain: 'ok'
    end
  end

  describe '#append_info_to_payload' do
    let(:user) { FactoryBot.create(:user) }

    it 'adds user_id, auth_strategy, and auth_client to payload' do
      allow(controller).to receive(:current_user).and_return(user)
      request.env['portal.auth_strategy'] = 'bearer_token'
      request.env['portal.auth_client'] = 'test_client'

      payload = {}
      controller.send(:append_info_to_payload, payload)

      expect(payload[:user_id]).to eq(user.id)
      expect(payload[:auth_strategy]).to eq('bearer_token')
      expect(payload[:auth_client]).to eq('test_client')
    end

    it 'handles nil current_user gracefully' do
      payload = {}
      controller.send(:append_info_to_payload, payload)

      expect(payload[:user_id]).to be_nil
      expect(payload[:auth_strategy]).to be_nil
    end
  end
end
