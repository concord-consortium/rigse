require 'spec_helper'

RSpec.describe ResearcherDashboard::Upstream do
  let(:url) { 'https://functions.example/researcherDashboard/derive-profile' }
  let(:warnings) { [] }

  before(:each) do
    allow(Rails.logger).to receive(:warn) { |message| warnings << message }
  end

  def post
    described_class.post_json(:function, url, body: { a: 1 }, bearer: 'the-bearer', read_timeout: 10)
  end

  def refusal_from
    yield
    raise 'expected a Refusal'
  rescue ResearcherDashboard::Refusal => e
    e
  end

  describe '.post_json' do
    it 'sends the body as JSON with the bearer' do
      stub = stub_request(:post, url)
        .with(body: '{"a":1}', headers: { 'Authorization' => 'Bearer the-bearer', 'Content-Type' => 'application/json' })
        .to_return(status: 202, body: '{}')
      expect(post.code).to eq(202)
      expect(stub).to have_been_requested
    end

    it 'turns a read timeout into a 504 and logs it' do
      stub_request(:post, url).to_raise(Net::ReadTimeout)
      e = refusal_from { post }
      expect(e.status).to eq(504)
      expect(e.details).to eq(upstream: 'report-service', status: nil, reason: 'Net::ReadTimeout')
      expect(warnings).to eq(['researcher_dashboard.upstream_refusal upstream=report-service status=nil reason="Net::ReadTimeout"'])
    end

    it 'turns an open timeout into a 504' do
      stub_request(:post, url).to_raise(Net::OpenTimeout)
      expect(refusal_from { post }.status).to eq(504)
    end

    [Errno::ECONNREFUSED, EOFError, SocketError, Net::HTTPBadResponse, OpenSSL::SSL::SSLError].each do |error|
      it "turns #{error} into a 502" do
        stub_request(:post, url).to_raise(error)
        e = refusal_from { post }
        expect(e.status).to eq(502)
        expect(e.message).to eq('report-service could not be reached')
        expect(warnings.size).to eq(1)
      end
    end

    it 'never logs the bearer' do
      stub_request(:post, url).to_raise(Net::ReadTimeout)
      refusal_from { post }
      expect(warnings.join).not_to include('the-bearer')
    end
  end

  describe '.get' do
    it 'sends the query and the bearer, and no Origin' do
      stub = stub_request(:get, 'https://rs.example/api/v1/packages/resolve?identity=projects%2F20%2Fa&version=1.0.0')
        .with { |request| request.headers['Authorization'] == 'Bearer tok' && !request.headers.key?('Origin') }
        .to_return(status: 200, body: '{}')
      described_class.get(:report_server, 'https://rs.example/api/v1/packages/resolve',
                          query: { identity: 'projects/20/a', version: '1.0.0' }, bearer: 'tok', read_timeout: 10)
      expect(stub).to have_been_requested
    end
  end

  describe '.reason' do
    def response_with(body, content_type = 'application/json')
      stub_request(:get, 'https://x.example/').to_return(status: 400, body: body, headers: { 'Content-Type' => content_type })
      HTTParty.get('https://x.example/')
    end

    it "reads report-server's envelope message" do
      expect(described_class.reason(response_with('{"error":"FORBIDDEN","message":"not yours"}'))).to eq('not yours')
    end

    it "reads runnable:false's reason first" do
      expect(described_class.reason(response_with('{"runnable":false,"reason":"archived","message":"m"}'))).to eq('archived')
    end

    it "reads the function's error" do
      expect(described_class.reason(response_with('{"success":false,"error":"queue at its cap (20 outstanding)"}'))).to eq('queue at its cap (20 outstanding)')
    end

    it 'reads a plain-text body' do
      expect(described_class.reason(response_with("  upstream fell over\n", 'text/plain'))).to eq('upstream fell over')
    end

    it 'reads an unparsable JSON body as text' do
      expect(described_class.reason(response_with('{not json'))).to eq('{not json')
    end

    it 'truncates to 300 characters' do
      expect(described_class.reason(response_with('x' * 1000, 'text/plain')).length).to eq(300)
    end
  end

  describe '.refusal' do
    it "carries the upstream's status and reason, and logs them" do
      stub_request(:post, url).to_return(status: 400, body: '{"error":"assignment_urls[3] is too long"}', headers: { 'Content-Type' => 'application/json' })
      e = described_class.refusal(:function, post, message: 'report-service refused the profile refresh')
      expect(e.status).to eq(502)
      expect(e.message).to eq('report-service refused the profile refresh: assignment_urls[3] is too long')
      expect(e.details).to eq(upstream: 'report-service', status: 400, reason: 'assignment_urls[3] is too long')
      expect(warnings).to eq(['researcher_dashboard.upstream_refusal upstream=report-service status=400 reason="assignment_urls[3] is too long"'])
    end

    it 'names the status when the upstream gives no reason' do
      stub_request(:post, url).to_return(status: 500, body: '')
      expect(described_class.refusal(:function, post).message).to eq('report-service answered 500')
    end
  end
end
