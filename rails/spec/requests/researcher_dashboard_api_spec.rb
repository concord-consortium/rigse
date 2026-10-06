require 'spec_helper'

# The dashboard API over the whole stack: the routes, the Devise JWT strategy that reads
# the access token, and the capability ceiling, none of which a controller spec exercises.
RSpec.describe 'Researcher Dashboard API', type: :request do
  include Devise::Test::IntegrationHelpers
  # Rails 8 draws routes lazily in test, and Devise registers its Warden strategies from
  # the routes' devise_for, so the first request of a process would otherwise be
  # authenticated without them.
  before(:all) { Rails.application.reload_routes_unless_loaded }

  include_context 'with the researcher dashboard configured'

  let(:cohort)  { FactoryBot.create(:admin_cohort) }
  let(:project) { FactoryBot.create(:project, cohorts: [cohort]) }
  let(:teacher) { FactoryBot.create(:portal_teacher, cohorts: [cohort]) }
  let(:clazz)   { FactoryBot.create(:portal_clazz, name: 'Class A', teachers: [teacher]) }
  let(:other)   { FactoryBot.create(:portal_clazz, name: 'Class B', teachers: [teacher]) }
  let(:researcher) do
    user = FactoryBot.create(:confirmed_user)
    user.add_role_for_project('researcher', project)
    user
  end

  def token_for(context_clazz, capabilities: [TokenCapabilities::CLASS_RESEARCHER_READ, TokenCapabilities::CLASS_RESEARCHER_RUN])
    SignedJwt.create_access_token(researcher, client_id: 'researcher-dashboard', capabilities: capabilities,
                                  context: { type: 'class', id: context_clazz.id },
                                  audiences: [APP_CONFIG[:site_url]], expires_in: 120)
  end

  def get_scope(token)
    get '/api/v1/researcher_dashboard/scope', headers: { 'Authorization' => "Bearer #{token}" }
    JSON.parse(response.body)
  end

  it 'describes the class the access token is bound to' do
    body = get_scope(token_for(clazz))
    expect(response.status).to eq(200)
    expect(body).to include('kind' => 'class', 'id' => clazz.id, 'name' => 'Class A', 'platform_user_id' => researcher.id)
  end

  it 'reaches only the class in the token, for a researcher who may open both' do
    expect(get_scope(token_for(other))).to include('id' => other.id, 'name' => 'Class B')
    expect(get_scope(token_for(clazz))).to include('id' => clazz.id, 'name' => 'Class A')
  end

  it 'stores no session for the access token' do
    get_scope(token_for(clazz))
    get '/api/v1/researcher_dashboard/scope'
    expect(response.status).to eq(401)
    # The unauthenticated refusal, not the unscoped one a stored session would have earned.
    expect(JSON.parse(response.body)['message']).to match(/must be logged in/)
  end

  it 'refuses a signed-in session, which carries no scope' do
    sign_in researcher
    get '/api/v1/researcher_dashboard/scope'
    expect(response.status).to eq(401)
    expect(JSON.parse(response.body)['message']).to match(/accept only a Researcher Dashboard access token/)
  end

  it 'refuses the run path to a token that may only read' do
    post '/api/v1/researcher_dashboard/run_package',
         params: JSON.generate(packages: [{ identity: 'projects/20/b', version: '1.0.0' }]),
         headers: { 'Authorization' => "Bearer #{token_for(clazz, capabilities: [TokenCapabilities::CLASS_RESEARCHER_READ])}",
                    'Content-Type' => 'application/json' }
    expect(response.status).to eq(403)
    expect(a_request(:get, /packages\/resolve/)).not_to have_been_made
    expect(a_request(:post, /run-package/)).not_to have_been_made
  end

  it 'refreshes the profile of the class in the token' do
    derive_url = 'https://functions.example/researcherDashboard/derive-profile'
    stub_request(:post, derive_url).to_return(status: 202, body: '{"queued":true}', headers: { 'Content-Type' => 'application/json' })
    post '/api/v1/researcher_dashboard/refresh_profile', headers: { 'Authorization' => "Bearer #{token_for(other)}" }
    expect(response.status).to eq(202)
    expect(JSON.parse(response.body)['queued']).to be true
    expect(a_request(:post, derive_url).with { |r| JSON.parse(r.body)['class_hash'] == other.class_hash }).to have_been_made.once
  end
end
