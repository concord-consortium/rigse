require 'spec_helper'

RSpec.describe ResearcherDashboard::RunPackage do
  include_context 'with the researcher dashboard configured'

  let(:project)    { FactoryBot.create(:project) }
  let(:teacher)    { FactoryBot.create(:portal_teacher, cohorts: [FactoryBot.create(:admin_cohort, project: project)]) }
  let(:clazz)      { FactoryBot.create(:portal_clazz, teachers: [teacher]) }
  let(:activity)   { FactoryBot.create(:external_activity, name: 'Moth 1.2', url: 'https://ap.example/?activity=1') }
  let!(:offering)  { FactoryBot.create(:portal_offering, clazz: clazz, runnable: activity) }
  let(:user)       { FactoryBot.create(:confirmed_user) }
  let(:run_url)    { 'https://functions.example/researcherDashboard/run-package' }
  let(:queue)      { [{ 'class_hash' => clazz.class_hash, 'package_key' => 'projects-20-b' }] }
  let(:accepted)   { { success: true, queue: queue, appended: ['projects-20-b'], vm: 'launched' } }
  let(:queue_state) { { 'queue' => queue, 'appended' => ['projects-20-b'], 'vm' => 'launched' } }

  before(:each) do
    FirebaseTestHelper.create_test_firebase_app(name: 'report-service-dev')
    FirebaseTestHelper.create_test_firebase_app(name: 'collaborative-learning-staging')
  end

  def checksum(n)
    "sha256:#{n.to_s * 64}"
  end

  def stub_resolve(identity, version = '1.0.0', status: 200, catalog_id: 12, clue_prepull: false, runnable: true, reason: nil)
    body = status == 200 ?
      { identity: identity, version: version, checksum: checksum(catalog_id % 10), catalog_id: catalog_id,
        clue_prepull: clue_prepull, archived: !runnable, runnable: runnable, reason: reason } :
      { error: 'NOT_FOUND', message: 'not found' }
    stub_request(:get, 'https://report-server.example/api/v1/packages/resolve')
      .with(query: { identity: identity, version: version })
      .to_return(status: status, body: JSON.generate(body), headers: { 'Content-Type' => 'application/json' })
  end

  def stub_run(status: 202, body: accepted, content_type: 'application/json')
    stub_request(:post, run_url).to_return(status: status, body: body.is_a?(String) ? body : JSON.generate(body),
                                           headers: { 'Content-Type' => content_type })
  end

  def run(packages)
    described_class.call(user: user, clazz: clazz, packages: packages, launch_token: 'launch-token')
  end

  def refusal(packages)
    run(packages)
    raise 'expected a Refusal'
  rescue ResearcherDashboard::Refusal => e
    e
  end

  def posted_body
    body = nil
    expect(a_request(:post, run_url).with { |r| body = JSON.parse(r.body) }).to have_been_made.once
    body
  end

  def firebase(token, app)
    SignedJwt.decode_firebase_token(token, app)[:data]
  end

  let(:packages) { [{ identity: 'projects/20/b', version: '1.0.0' }, { identity: 'users/7/a', version: '2.0.0' }] }

  it 'posts the resolved packages, the scope, the tokens and the assertions, and returns the queue state' do
    stub_resolve('projects/20/b', catalog_id: 12)
    stub_resolve('users/7/a', '2.0.0', catalog_id: 13)
    stub_run(body: accepted.merge(extra: 'dropped'))

    expect(run(packages)).to eq(queue_state)

    body = posted_body
    expect(body.keys).to match_array(%w[packages scope class_tokens session_token firebase_project report_server_assertion])
    expect(body['packages']).to eq([
      { 'identity' => 'projects/20/b', 'version' => '1.0.0', 'checksum' => checksum(2), 'catalog_id' => 12 },
      { 'identity' => 'users/7/a', 'version' => '2.0.0', 'checksum' => checksum(3), 'catalog_id' => 13 }
    ])
    expect(body['scope']).to eq(
      'kind' => 'class', 'collection' => 'classes', 'id' => clazz.class_hash,
      'classes' => [{ 'class_hash' => clazz.class_hash, 'class_id' => clazz.id }],
      'assignments' => [{ 'offering_id' => offering.id, 'runnable_id' => activity.id, 'name' => 'Moth 1.2', 'url' => 'https://ap.example/?activity=1' }]
    )
    expect(body['firebase_project']).to eq('report-service-dev')
    expect(body['class_tokens'].keys).to eq(['report-service-dev'])
    expect(firebase(body['class_tokens']['report-service-dev'], 'report-service-dev')['claims'])
      .to include('class_hash' => clazz.class_hash, 'researcher_dashboard_runner' => true)
    session = firebase(body['session_token'], 'report-service-dev')['claims']
    expect(session).to include('researcher_dashboard_runner' => true)
    expect(session).not_to have_key('class_hash')
    assertion = SignedJwt.decode_portal_token(body['report_server_assertion'], aud: SignedJwt::AUD_REPORT_SERVER)[:data]
    expect(assertion).to include('uid' => user.id, 'scope_id' => clazz.id)
    expect(a_request(:post, run_url).with { |r|
      bearer = r.headers['Authorization'].sub(/\ABearer /, '')
      SignedJwt.decode_portal_token(bearer, aud: SignedJwt::AUD_REPORT_SERVICE_FUNCTIONS)[:data]['uid'] == user.id
    }).to have_been_made.once
  end

  it 'mints a CLUE class token when a package declares clue_prepull' do
    stub_resolve('projects/20/b', clue_prepull: true)
    stub_run
    run(packages.first(1))
    tokens = posted_body['class_tokens']
    expect(tokens.keys).to eq(%w[report-service-dev collaborative-learning-staging])
    expect(firebase(tokens['collaborative-learning-staging'], 'collaborative-learning-staging')['claims'])
      .to include('class_hash' => clazz.class_hash, 'researcher_dashboard_runner' => true)
  end

  it 'queues none of five packages when the third cannot be resolved' do
    five = (1..5).map { |i| { identity: "users/7/p#{i}", version: '1.0.0' } }
    stub_resolve('users/7/p1')
    stub_resolve('users/7/p2')
    stub_resolve('users/7/p3', status: 404)
    e = refusal(five)
    expect(e.status).to eq(409)
    expect(e.message).to start_with('users/7/p3@1.0.0 cannot be resolved')
    expect(a_request(:get, /packages\/resolve/)).to have_been_made.times(3)
    expect(a_request(:post, run_url)).not_to have_been_made
  end

  it 'refuses an archived package with a 409 and sends nothing' do
    stub_resolve('projects/20/b', runnable: false, reason: 'archived')
    e = refusal(packages.first(1))
    expect(e.status).to eq(409)
    expect(e.message).to eq('projects/20/b@1.0.0 cannot be run: archived')
    expect(a_request(:post, run_url)).not_to have_been_made
  end

  context 'when the function refuses' do
    before(:each) { stub_resolve('projects/20/b') }

    it 'passes its 409 through with its reason' do
      stub_run(status: 409, body: { success: false, error: 'queue at its cap (20 outstanding)' })
      e = refusal(packages.first(1))
      expect(e.status).to eq(409)
      expect(e.message).to eq('report-service refused the run: queue at its cap (20 outstanding)')
    end

    it 'turns its 503 into a 502 carrying its reason' do
      reason = 'researcherDashboard is not configured: RD_MICROVM_IMAGE_ARN unset'
      stub_run(status: 503, body: { success: false, error: reason })
      e = refusal(packages.first(1))
      expect(e.status).to eq(502)
      expect(e.details).to eq(upstream: 'report-service', status: 503, reason: reason)
    end

    it 'turns a plain-text 502 into a 502 carrying the text' do
      stub_run(status: 502, body: 'report-server mint failed: 500', content_type: 'text/plain')
      e = refusal(packages.first(1))
      expect(e.status).to eq(502)
      expect(e.details[:reason]).to eq('report-server mint failed: 500')
    end

    it 'says a timeout may have queued the work' do
      stub_request(:post, run_url).to_raise(Net::ReadTimeout)
      e = refusal(packages.first(1))
      expect(e.status).to eq(504)
      expect(e.message).to eq('report-service did not answer in time; the packages may already be queued')
    end

    [['a text body', 'queued', 'text/plain'],
     ['a JSON object without the queue state', '{"success":true}', 'application/json'],
     ['a queue that is not a list', '{"queue":1,"appended":[],"vm":"running"}', 'application/json'],
     ['JSON that does not parse', '{"queue":', 'application/json']].each do |label, body, content_type|
      it "refuses a 202 with #{label} with a 502" do
        stub_run(body: body, content_type: content_type)
        e = refusal(packages.first(1))
        expect(e.status).to eq(502)
        expect(e.details).to eq(upstream: 'report-service', status: 202, reason: 'malformed 202 body')
      end
    end
  end

  it 'answers a resolve timeout with a plain 504' do
    stub_request(:get, /packages\/resolve/).to_raise(Net::ReadTimeout)
    e = refusal(packages.first(1))
    expect(e.status).to eq(504)
    expect(e.message).to eq('report-server did not answer in time')
  end

  context 'when a configured FirebaseApp has no row' do
    it 'refuses before minting or sending anything' do
      FirebaseApp.where(name: 'collaborative-learning-staging').delete_all
      stub_resolve('projects/20/b', clue_prepull: true)
      expect { run(packages.first(1)) }
        .to raise_error(ResearcherDashboard::Settings::NotConfigured, /RESEARCHER_DASHBOARD_CLUE_FIREBASE_APP names FirebaseApp collaborative-learning-staging, which does not exist/)
      expect(a_request(:post, run_url)).not_to have_been_made
    end
  end

  context 'without the CLUE FirebaseApp configured' do
    before(:each) { ENV.delete('RESEARCHER_DASHBOARD_CLUE_FIREBASE_APP') }

    it 'still runs a batch without clue_prepull' do
      stub_resolve('projects/20/b')
      stub_run
      expect(run(packages.first(1))).to eq(queue_state)
    end

    it 'refuses a batch with clue_prepull and sends nothing' do
      stub_resolve('projects/20/b', clue_prepull: true)
      expect { run(packages.first(1)) }.to raise_error(ResearcherDashboard::Settings::NotConfigured, /RESEARCHER_DASHBOARD_CLUE_FIREBASE_APP/)
      expect(a_request(:post, run_url)).not_to have_been_made
    end
  end
end
