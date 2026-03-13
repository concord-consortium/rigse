require 'spec_helper'

RSpec.describe API::V1::EmailPolicy do
  let(:user) { FactoryBot.create(:user) }

  def context_with(user:, auth_strategy:)
    req = double('request', env: { 'portal.auth_strategy' => auth_strategy })
    double('context', user: user, request: req, params: {})
  end

  describe '#oidc_send?' do
    it 'allows OIDC-authenticated users' do
      policy = described_class.new(context_with(user: user, auth_strategy: 'oidc_bearer_token'), nil)
      expect(policy.oidc_send?).to be true
    end

    it 'denies non-OIDC users' do
      policy = described_class.new(context_with(user: user, auth_strategy: 'api_jwt'), nil)
      expect(policy.oidc_send?).to be false
    end

    it 'denies when no user' do
      policy = described_class.new(context_with(user: nil, auth_strategy: 'oidc_bearer_token'), nil)
      expect(policy.oidc_send?).to be_falsey
    end
  end
end
