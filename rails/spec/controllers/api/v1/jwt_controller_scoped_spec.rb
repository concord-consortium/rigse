require 'spec_helper'

# jwt/firebase's researcher mint is the one jwt/* action a scoped token may use, and only for
# the class the token is bound to.
RSpec.describe API::V1::JwtController, type: :controller do
  before(:each) { generate_default_settings_with_mocks }
  after(:each) { Current.reset }

  let(:cohort)       { FactoryBot.create(:admin_cohort) }
  let(:project)      { FactoryBot.create(:project, cohorts: [cohort]) }
  let(:teacher)      { FactoryBot.create(:portal_teacher, cohorts: [cohort]) }
  let(:clazz)        { FactoryBot.create(:portal_clazz, teachers: [teacher]) }
  let(:other)        { FactoryBot.create(:portal_clazz, teachers: [teacher]) }
  let(:firebase_app) { FactoryBot.create(:firebase_app) }
  let(:researcher) do
    u = FactoryBot.create(:confirmed_user)
    u.add_role_for_project('researcher', project)
    u
  end

  def present(capabilities, context_clazz)
    token = SignedJwt.create_access_token(researcher, client_id: 'c', capabilities: capabilities,
                                          context: { type: 'class', id: context_clazz.id },
                                          audiences: [APP_CONFIG[:site_url]], expires_in: 60)
    Current.reset
    request.headers['Authorization'] = "Bearer #{token}"
  end

  it 'mints a researcher Firebase token for the class the token is bound to' do
    present(['class:researcher-read'], clazz)
    get :firebase, params: { firebase_app: firebase_app.name, researcher: 'true', class_hash: clazz.class_hash }, format: :json
    expect(response).to have_http_status(:created)
  end

  it "refuses another class, even one the researcher could open, with the endpoint's 400" do
    present(['class:researcher-read'], clazz)
    get :firebase, params: { firebase_app: firebase_app.name, researcher: 'true', class_hash: other.class_hash }, format: :json
    expect(response).to have_http_status(:bad_request)
  end

  it 'refuses a token without class:researcher-read, and any non-researcher or POST request' do
    present(['class:researcher-run'], clazz)
    get :firebase, params: { firebase_app: firebase_app.name, researcher: 'true', class_hash: clazz.class_hash }, format: :json
    expect(response).to have_http_status(:forbidden)

    present(['class:researcher-read'], clazz)
    get :firebase, params: { firebase_app: firebase_app.name }, format: :json
    expect(response).to have_http_status(:forbidden)

    present(['class:researcher-read'], clazz)
    post :firebase, params: { firebase_app: firebase_app.name, researcher: 'true', class_hash: clazz.class_hash }, format: :json
    expect(response).to have_http_status(:forbidden)
  end

  it 'still runs the researcher gate for the matching class' do
    outsider = FactoryBot.create(:confirmed_user)
    token = SignedJwt.create_access_token(outsider, client_id: 'c', capabilities: ['class:researcher-read'],
                                          context: { type: 'class', id: clazz.id },
                                          audiences: [APP_CONFIG[:site_url]], expires_in: 60)
    request.headers['Authorization'] = "Bearer #{token}"
    get :firebase, params: { firebase_app: firebase_app.name, researcher: 'true', class_hash: clazz.class_hash }, format: :json
    expect(response).to have_http_status(:bad_request)
    expect(response.body).to match(/do not have access/)
  end
end
