require File.expand_path('../../spec_helper', __FILE__)

describe AccessGrant do
  let(:user) { FactoryBot.create(:user) }

  let(:valid_attributes) do
    {
      :client_id => 'application',
      :state     => 'what_is_this_for',
      :without_protection => true,
      :user      => user
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
  end

  describe "instance methods" do
    describe "#start_expiry_period!" do
      it "should set the expiration date" do
        subject.start_expiry_period!
        expect(subject.access_token_expires_at).to be_within(1.hour).of(7.days.from_now)
      end
    end

    describe "#redirect_uri_for" do
      let(:url)      { "http://blarg.com/path" }
      it "should include the token and state" do
        expect(subject.redirect_uri_for(url)).to match /#{url}\?code=[a-f|0-9]{32}&response_type=code&state=what_is_this_for/
      end
      describe "with qeury string in the url" do
        let(:url)      { "http://blarg.com/path?foo" }
        it "should use ampersands" do
          expect(subject.redirect_uri_for(url)).to match /path\?foo&code=/
        end
      end

    end
  end


  # TODO: auto-generated
  describe '.valid_at' do # scope test
    it 'supports named scope valid_at' do
      expect(described_class.limit(3).valid_at(Time.now)).to all(be_a(described_class))
    end
  end

  # TODO: auto-generated
  describe '.prune!' do
    it 'prune!' do
      result = described_class.prune!

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.authenticate' do
    it 'authenticate' do
      code = double('code')
      application_id = double('application_id')
      result = described_class.authenticate(code, application_id)

      expect(result).to be_nil
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

  # TODO: auto-generated
  describe '#redirect_uri_for' do
    xit 'redirect_uri_for' do
      access_grant = described_class.new
      redirect_uri = double('redirect_uri')
      result = access_grant.redirect_uri_for(redirect_uri)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#start_expiry_period!' do
    it 'start_expiry_period!' do
      access_grant = described_class.new
      result = access_grant.start_expiry_period!

      expect(result).not_to be_nil
    end
  end


end
