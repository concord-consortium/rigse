require File.expand_path('../../spec_helper', __FILE__)

describe AccessGrant do
  let(:user) { FactoryBot.create(:user) }
  let(:client) { FactoryBot.create(:client) }

  let(:valid_attributes) do
    {
      :client_id => client.id,
      :state => 'what_is_this_for',
      :without_protection => true,
      :user => user
    }
  end

  let(:old_grants) do
    attributes = {
      :client_id => 'a',
      :state     => 'b',
      :without_protection => true,
      :access_token_expires_at => 2.days.ago
    }
    3.times.map { |i| AccessGrant.create(attributes) }
  end

  let(:newer_grants) do
    attributes = {
      :client_id => 'a',
      :state     => 'b',
      :without_protection => true,
      :access_token_expires_at => 0.days.ago
    }
    2.times.map { |i| AccessGrant.create(attributes) }
  end

  subject{ AccessGrant.create(valid_attributes)}

  describe "class methods" do
    describe "#new with valid attributes" do
      it "should return a valid instance with parameters set" do
        expect(subject).to be_valid
      end
      it "should have valid tokens" do
        expect(subject.code).to match /[a-f|0-9]{32}/
        expect(subject.access_token).to match /[a-f|0-9]{32}/
        expect(subject.refresh_token).to match(/[a-f|0-9]{32}/)
      end
      it "should not have an expiration time" do
        expect(subject.access_token_expires_at).to be_nil
      end
    end

    describe "#prune!" do
      it "Should remove items that expired more than a day ago" do
        all_grants = old_grants + newer_grants
        expect(AccessGrant.count).to eq(all_grants.size)
        AccessGrant.prune!
        expect(AccessGrant.count).to eq(newer_grants.size)
        AccessGrant.pluck('access_token_expires_at').each do |exp_time|
          expect(exp_time).to be > 1.days.ago
        end
      end
    end

    describe "#validate_oauth_authorize" do
      let(:params) { {} }
      let(:client_attributes) { {} }
      let(:client) { FactoryBot.create(:client, client_attributes) }
      subject {
        AccessGrant.validate_oauth_authorize(params)
      }
      context "when response_type is 'token'" do
        let(:params) { {client_id: client.app_id, response_type: "token", redirect_uri: "http://test.com"} }
        let(:client_attributes) {
          {redirect_uris: "http://test.com", client_type: Client::PUBLIC} }

        it { should be_valid }
      end

      context "when response_type is 'token'" do
        let(:params) { {client_id: client.app_id, response_type: "code", redirect_uri: "http://test.com"} }
        let(:client_attributes) {
          {redirect_uris: "http://test.com", client_type: Client::CONFIDENTIAL} }

        it { should be_valid }
      end

      context "when client_id is not found" do
        let(:params) { {client_id: "123"} }
        it "should raise an error" do
          expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "when response_type is not supported and redirect_uri is not registered" do
        let(:params) { {client_id: client.app_id, response_type: "foo"} }
        it "should raise an error" do
          expect { subject }.to raise_error(RuntimeError)
        end
      end

      context "when response_type is not supported and redirect_uri is registered" do
        let(:params) { {client_id: client.app_id, response_type: "foo", redirect_uri: "http://test.com" } }
        let(:client_attributes) {
          {redirect_uris: "http://test.com"} }

        it { should_not be_valid }

        it "should return an error_redirect" do
          expect(subject.error_redirect).to eq("http://test.com?error=unsupported_response_type")
        end
      end

      mismatched_pairs = [
        {client_type: Client::CONFIDENTIAL, response_type: "token"},
        {client_type: Client::PUBLIC,       response_type: "code"}
      ]
      mismatched_pairs.each do |pair|
        context "when response_type is '#{pair[:response_type]} and client_type is '#{pair[:client_type]}''" do
          let(:redirect_uri_param) { nil }
          let(:params) { {
            client_id: client.app_id,
            response_type: pair[:response_type],
            redirect_uri: redirect_uri_param } }
          let(:client_attributes) { {
            client_type: pair[:client_type],
            redirect_uris: "http://test.com"} }

          context "when the redirect_uri is not registerd" do
            it "should raise an error" do
              expect { subject }.to raise_error(RuntimeError)
            end
          end
          context "when the redirect_uri is registered" do
            let(:redirect_uri_param) { "http://test.com" }

            it { should_not be_valid }

            it "should return an error_redirect" do
              expect(subject.error_redirect).to eq("http://test.com?error=unauthorized_client")
            end
          end
        end
      end
    end

    describe "#get_authorize_redirect_uri" do
      let (:params) { {} }
      subject { AccessGrant.get_authorize_redirect_uri(user, params) }
      context "when validation raises an error" do
        before(:each) {
          expect(AccessGrant).to receive(:validate_oauth_authorize)
            .and_raise("Mock Error")
        }
        it "should raise an error" do
          expect { subject }.to raise_error(RuntimeError)
        end
      end

      context "when validation is not valid" do
         before(:each) {
           expect(AccessGrant).to receive(:validate_oauth_authorize)
             .and_return(AccessGrant::ValidationResult.new(false, nil, "http://error.redirect"))
         }
         it "returns error redirect" do
           expect(subject).to eq("http://error.redirect")
         end
      end

      context "when validation is valid" do
        let(:client) { FactoryBot.create(:client, redirect_uris: "http://test.com") }
        let(:response_type_param) { }
        let(:params) { {
            response_type: response_type_param,
            redirect_uri: "http://test.com"
          }}
        before(:each) {
          expect(AccessGrant).to receive(:validate_oauth_authorize)
            .and_return(AccessGrant::ValidationResult.new(true, client, nil))
        }

        it "should prune old access grants" do
          expect(AccessGrant).to receive(:prune!)
          # the subject will raise an error because there is no response_type_param
          expect{ subject }.to raise_error(RuntimeError)
        end
        context "when response_type is 'token'" do
          let(:response_type_param) { "token" }
          it "should return redirect_uri with access token" do
            expect(subject).to eq(
              "http://test.com#access_token=#{AccessGrant.last.access_token}&token_type=bearer&expires_in=#{AccessGrant::ExpireTime.to_s}&state")
          end
        end
        context "when response_type is 'code'" do
          let(:response_type_param) { "code" }
          it "should return redirect_uri with code" do
            expect(subject).to eq(
              "http://test.com?code=#{AccessGrant.last.code}&response_type=code&state=")
          end
        end
      end
    end

    describe "#authenticate(code, application_id)" do
      before(:each) do
        all_grants  = old_grants + newer_grants
        AccessGrant.prune!
      end
      it "should return a non-expired token" do
        grant = newer_grants.first
        expect(AccessGrant.authenticate(grant.code, grant.client_id)).not_to be_nil
      end
      describe "with an expired token" do
        it "should return nil" do
          grant = old_grants.first
          expect(AccessGrant.authenticate(grant.code, grant.client_id)).to be_nil
        end
      end
    end

    # TODO: auto-generated
    describe '#valid_at' do # scope test
      it 'supports named scope valid_at' do
        expect(described_class.limit(3).valid_at(Time.now)).to all(be_a(described_class))
      end
    end

  end

  describe "instance methods" do
    describe "#start_expiry_period!" do
      it "should set the expiration date" do
        subject.start_expiry_period!
        expect(subject.access_token_expires_at).to be_within(1.hour).of(7.days.from_now)
      end
    end

    describe "#auth_code_redirect_uri_for" do
      let(:client) { FactoryBot.create(:client, redirect_uris: url) }
      let(:url) { "http://blarg.com/path" }
      it "should include the token and state" do
        expect(subject.auth_code_redirect_uri_for(url)).to match /#{url}\?code=[a-f|0-9]{32}&response_type=code&state=what_is_this_for/
      end
      describe "with qeury string in the url" do
        let(:url) { "http://blarg.com/path?foo" }
        it "should use ampersands" do
          expect(subject.auth_code_redirect_uri_for(url)).to match /path\?code=[A-Za-z0-9]+&foo=/
        end
      end
    end

    describe "#implicit_flow_redirect_uri_for" do
      let(:client) { FactoryBot.create(:client, redirect_uris: url) }
      let(:url) { "http://blarg.com/path" }
      it "should include the token and state" do
        expect(subject.implicit_flow_redirect_uri_for(url)).to match /#{url}\#access_token=[a-f|0-9]{32}&token_type=bearer&expires_in=\d+&state=what_is_this_for/
      end
    end

    # TODO: auto-generated
    describe '#generate_tokens' do
      it 'generate_tokens' do
        access_grant = described_class.new
        result = access_grant.generate_tokens

        expect(result).not_to be_nil
      end
    end

  end




end
