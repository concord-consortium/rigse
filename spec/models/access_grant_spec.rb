require File.expand_path('../../spec_helper', __FILE__)

describe AccessGrant do
  let(:user) { FactoryGirl.create(:user) }

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
        subject.should be_valid
      end
      it "should have valid tokens" do
        subject.code.should match /[a-f|0-9]{32}/
        subject.access_token.should match /[a-f|0-9]{32}/
        subject.refresh_token.should match(/[a-f|0-9]{32}/)
      end
      it "should not have an expiration time" do
        subject.access_token_expires_at.should be_nil
      end
    end
    describe "#prune!" do
      it "Should remove items that expired more than a day ago" do
        all_grants = old_grants + newer_grants
        AccessGrant.count.should == all_grants.size
        AccessGrant.prune!
        AccessGrant.count.should == newer_grants.size
        AccessGrant.pluck('access_token_expires_at').each do |exp_time|
          exp_time.should be > 1.days.ago
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
        AccessGrant.authenticate(grant.code, grant.client_id).should_not be_nil
      end
      describe "with an expired token" do
        it "should return nil" do
          grant = old_grants.first
          AccessGrant.authenticate(grant.code, grant.client_id).should be_nil
        end
      end
    end
  end

  describe "instance methods" do
    describe "#start_expiry_period!" do
      it "should set the expiration date" do
        subject.start_expiry_period!
        subject.access_token_expires_at.should be_within(1.hour).of(7.days.from_now)
      end
    end

    describe "#redirect_uri_for" do
      let(:url)      { "http://blarg.com/path" }
      it "should include the token and state" do
        subject.redirect_uri_for(url).should match /#{url}\?code=[a-f|0-9]{32}&response_type=code&state=what_is_this_for/
      end
      describe "with qeury string in the url" do
        let(:url)      { "http://blarg.com/path?foo" }
        it "should use ampersands" do
          subject.redirect_uri_for(url).should match /path\?foo&code=/
        end
      end

    end
  end

end
