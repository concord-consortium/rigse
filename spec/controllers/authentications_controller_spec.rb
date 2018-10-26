# frozen_string_literal: false

require 'spec_helper'

RSpec.describe AuthenticationsController, type: :controller do

  let(:uid_value) { '12345' }

  before(:each) do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    @request.env['omniauth.origin'] = double()
  end

  describe '#google' do
    it 'GET google' do
      @request.env['omniauth.auth'] = double(
        extra: double(
          username: nil,
          first_name: 'Fake',
          last_name: 'Fakerson'
        ),
        info: double(
          email: 'fakename@fakedomain.org',
          uid: uid_value
        ),
        provider: 'google',
        uid: uid_value
      )
      get :google

      expect(response).to have_http_status(302)
    end
  end

  describe '#schoology' do
    it 'GET schoology' do
      @request.env['omniauth.auth'] = double(
        extra: double(
          username: 'fakename',
          user_id: uid_value,
          domain: 'fakedomain.org',
          first_name: 'Fake',
          last_name: 'Fakerson'
        ),
        info: double(
          email: 'fakename@fakedomain.org'
        ),
        provider: 'schoology',
        uid: uid_value
      )

      get :schoology

      expect(response).to have_http_status(302)
    end
  end

end
