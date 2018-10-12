# frozen_string_literal: false

require 'spec_helper'

RSpec.describe AuthenticationsController, type: :controller do

  before(:each) do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    @request.env['omniauth.origin'] = double()
    @uid_value = '12345'
    @extra_values = double(
                      username: nil,
                      first_name: 'Fake',
                      last_name: 'Fakerson'
                    )
    @info_values = double(
                     email: 'fakename@fakedomain.org',
                     uid: @uid_value
                   )
  end

  describe '#google' do
    it 'GET google' do
      @request.env['omniauth.auth'] = double(
        extra: @extra_values,
        info: @info_values,
        provider: 'google',
        uid: @uid_value
      )
      get :google

      expect(response).to have_http_status(302)
    end
  end

  describe '#schoology' do
    it 'GET schoology' do
      @request.env['omniauth.auth'] = double(
        extra: @extra_values,
        info: @info_values,
        provider: 'schoology',
        uid: @uid_value
      )

      get :schoology

      expect(response).to have_http_status(302)
    end
  end

end
