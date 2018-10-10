# frozen_string_literal: false

require 'spec_helper'

RSpec.describe AuthenticationsController, type: :controller do

  describe '#google' do
    it 'GET google' do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      @request.env['omniauth.auth'] = double(
        extra: double(
          username: nil,
          first_name: 'Fake',
          last_name: 'Fakerson'
        ),
        info: double(
          email: 'fakename@fakedomain.org',
          uid: '12345'
        ),
        provider: 'google',
        uid: '12345'
      )
      @request.env['omniauth.origin'] = double()
      get :google

      expect(response).to have_http_status(302)
    end
  end

end
