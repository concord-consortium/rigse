require 'spec_helper'

describe MiscController do

  describe "GET preflight" do
  	it "returns the preflight page without error" do
  	  get :preflight
  	end
  end

  # TODO: auto-generated
  describe '#stats' do
    it 'GET stats' do
      get :stats, xhr: true

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#auth_check' do
    xit 'GET auth_check' do
      get :auth_check, params: { provider: 'provider' }

      expect(response).to have_http_status(:ok)
    end
  end

end
