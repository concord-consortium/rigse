require 'spec_helper'

RSpec.describe ResearcherDashboard::Catalog do
  include_context 'with the researcher dashboard configured'

  let(:identity) { 'projects/20/class-counts' }
  let(:checksum) { "sha256:#{'a' * 64}" }
  let(:resolve_url) { 'https://report-server.example/api/v1/packages/resolve?identity=projects%2F20%2Fclass-counts&version=1.0.0' }
  let(:answer) {
    { identity: identity, version: '1.0.0', checksum: checksum, catalog_id: 12, expected_duration_seconds: 30,
      clue_prepull: false, archived: false, runnable: true, reason: nil }
  }

  def stub_resolve(status, body)
    stub_request(:get, resolve_url).to_return(status: status, body: body.is_a?(String) ? body : JSON.generate(body),
                                              headers: { 'Content-Type' => 'application/json' })
  end

  def resolve
    described_class.resolve(identity: identity, version: '1.0.0', launch_token: 'launch-token')
  end

  def refusal
    resolve
    raise 'expected a Refusal'
  rescue ResearcherDashboard::Refusal => e
    e
  end

  it 'sends the launch token and no Origin, and returns the checksum and catalog id' do
    stub = stub_resolve(200, answer)
    expect(resolve).to eq(identity: identity, version: '1.0.0', checksum: checksum, catalog_id: 12, clue_prepull: false)
    expect(a_request(:get, resolve_url).with { |r| r.headers['Authorization'] == 'Bearer launch-token' && !r.headers.key?('Origin') })
      .to have_been_made.once
    expect(stub).to have_been_requested
  end

  it 'reads clue_prepull, and treats its absence as false' do
    stub_resolve(200, answer.merge(clue_prepull: true))
    expect(resolve[:clue_prepull]).to be true
    stub_resolve(200, answer.except(:clue_prepull))
    expect(resolve[:clue_prepull]).to be false
  end

  it 'turns a 404 into a 409 saying the package cannot be resolved' do
    stub_resolve(404, { error: 'NOT_FOUND', message: 'no such package' })
    e = refusal
    expect(e.status).to eq(409)
    expect(e.message).to start_with('projects/20/class-counts@1.0.0 cannot be resolved: it does not exist or you may not see it')
    expect(e.details).to include(upstream: 'report-server', status: 404)
  end

  it "turns runnable: false into a 409 naming report-server's reason" do
    stub_resolve(200, answer.merge(archived: true, runnable: false, reason: 'archived'))
    e = refusal
    expect(e.status).to eq(409)
    expect(e.message).to eq('projects/20/class-counts@1.0.0 cannot be run: archived')
    expect(e.details).to eq(upstream: 'report-server', status: 200, reason: 'archived')
  end

  {
    'identity' => { identity: 'projects/20/other' },
    'version' => { version: '1.0.1' },
    'checksum' => { checksum: 'a' * 64 },
    'catalog_id' => { catalog_id: '12' },
    'runnable' => { runnable: nil }
  }.each do |field, change|
    it "refuses a 200 whose #{field} is wrong with a 502" do
      stub_resolve(200, answer.merge(change))
      e = refusal
      expect(e.status).to eq(502)
      expect(e.details).to eq(upstream: 'report-server', status: 200, reason: 'malformed resolve answer')
    end
  end

  it 'refuses a 200 whose JSON does not parse with a 502' do
    stub_resolve(200, '{"identity":')
    e = refusal
    expect(e.status).to eq(502)
    expect(e.details).to eq(upstream: 'report-server', status: 200, reason: 'malformed resolve answer')
  end

  it "turns a 503 into a 502 carrying report-server's message" do
    stub_resolve(503, { error: 'UNAVAILABLE', message: 'portal did not answer' })
    e = refusal
    expect(e.status).to eq(502)
    expect(e.message).to eq('report-server could not resolve projects/20/class-counts@1.0.0: portal did not answer')
    expect(e.details).to eq(upstream: 'report-server', status: 503, reason: 'portal did not answer')
  end

  it 'turns a timeout into a 504' do
    stub_request(:get, resolve_url).to_raise(Net::ReadTimeout)
    expect(refusal.status).to eq(504)
  end

  it 'logs each refusal once' do
    warnings = []
    allow(Rails.logger).to receive(:warn) { |m| warnings << m }
    stub_resolve(404, { error: 'NOT_FOUND', message: 'no such package' })
    refusal
    stub_resolve(200, answer.merge(catalog_id: 0))
    refusal
    expect(warnings).to eq([
      'researcher_dashboard.upstream_refusal upstream=report-server status=404 reason="no such package"',
      'researcher_dashboard.upstream_refusal upstream=report-server status=200 reason="malformed resolve answer"'
    ])
  end
end
