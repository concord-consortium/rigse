require 'spec_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    accepts_token_capability TokenCapabilities::CLASS_RESEARCHER_READ, only: [:declared, :object_check]

    def declared
      render plain: 'declared'
    end

    def undeclared
      render plain: 'undeclared'
    end

    def object_check
      require_token_capability!(TokenCapabilities::CLASS_RESEARCHER_READ, Portal::Clazz.find(params[:id]))
      render plain: 'ok'
    end
  end

  before(:each) do
    routes.draw do
      get 'declared' => 'anonymous#declared'
      get 'undeclared' => 'anonymous#undeclared'
      get 'object_check' => 'anonymous#object_check'
    end
  end
  after(:each) { Current.reset }

  let(:user)  { FactoryBot.create(:confirmed_user) }
  let(:clazz) { FactoryBot.create(:portal_clazz) }

  def bearer(claims)
    request.headers['Authorization'] = "Bearer #{SignedJwt.create_portal_token(user, claims)}"
    Current.reset
  end

  it 'lets a scoped token through only where one of its capabilities is declared' do
    bearer(scope: 'class:researcher-read')
    get :declared
    expect(response.body).to eq('declared')
    get :undeclared
    expect(response.status).to eq(403)
  end

  it 'reads the header as check_for_auth_token does, so extra whitespace hides nothing' do
    token = SignedJwt.create_portal_token(user, { scope: 'class:researcher-read' })
    ["Bearer\t#{token}", "Bearer  #{token}", "Bearer/JWT  #{token}"].each do |header|
      Current.reset
      request.headers['Authorization'] = header
      get :undeclared
      expect(response.status).to eq(403), header.inspect
    end
  end

  it 'limits a scoped access token sent as Bearer/JWT, which no authenticator accepts' do
    token = SignedJwt.create_access_token(user, client_id: 'c', capabilities: ['class:researcher-read'], context: nil,
                                          audiences: [APP_CONFIG[:site_url]], expires_in: 600)
    request.headers['Authorization'] = "Bearer/JWT #{token}"
    Current.reset
    get :undeclared
    expect(response.status).to eq(403)
  end

  it 'never affects an unscoped credential' do
    bearer({})
    get :undeclared
    expect(response.body).to eq('undeclared')
  end

  it 'ignores a bearer that does not verify' do
    request.headers['Authorization'] = 'Bearer a.b.c'
    get :undeclared
    expect(response.body).to eq('undeclared')
  end

  it 'refuses a context-bound capability outside the token context with 403' do
    bearer(scope: 'class:researcher-read', context: { type: 'class', id: clazz.id + 1 })
    get :object_check, params: { id: clazz.id }
    expect(response.status).to eq(403)
    expect(JSON.parse(response.body)['message']).to eq('This token does not allow class:researcher-read here')
  end

  it 'allows a context-bound capability on the token context' do
    bearer(scope: 'class:researcher-read', context: { type: 'class', id: clazz.id })
    get :object_check, params: { id: clazz.id }
    expect(response.body).to eq('ok')
  end
end
