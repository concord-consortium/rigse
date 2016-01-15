require 'spec_helper'
require 'delorean'
def addToken(user, client, expires_at)
  grant = user.access_grants.create({
      :client => client,
      :state => nil,
      :access_token_expires_at => expires_at },
    :without_protection => true
  )
  grant.access_token
end

describe BearerToken:BearerTokenAuthenticatable do
  after(:each) { Delorean.back_to_the_present }

  let(:strategy)  { BearerTokenAuthenticatable::BearerToken.new(nil) }
  let(:request)   { mock('request') }
  let(:mapping)   { Devise.mappings[:user] }
  let(:expires)   { Time.now + 10.minutes}
  let(:token)     { addToken(user, client, expires) }
  let(:headers)   { {"Authorization" => "Bearer #{token}"} }
  let(:user)      { FactoryGirl.create(:user) }
  let(:params)    { {} }
  let(:client)    { Client.find_or_create_by_name(
         :name       => "test_api_client",
         :app_id     => "test_api_client",
         :app_secret => SecureRandom.uuid
  )}
  before(:each) {
    request.stub!(:headers).and_return(headers)
    request.stub!(:params).and_return(params)
    strategy.stub!(:mapping).and_return(mapping)
    strategy.stub!(:request).and_return(request)
  }

  context 'a user with a short-lived authentication token' do
    let(:expires) { Time.now + 10.minutes}
    it 'should authenticate the user' do
      strategy.authenticate!.should eql :success
    end

    it 'the token should expire 12 minutes into the futre' do
      Delorean.jump(12 * 60) # move 12 minutes into the future
      strategy.authenticate!.should eql :failure
    end
  end

  context 'a user with an expired authentication token' do
    let(:expires) { Time.now - 10.minutes}
    it 'should NOT authenticate the user' do
      strategy.authenticate!.should eql :failure
    end
  end

  context 'a user with one expired authentication token, and a valid token' do
    let(:good_token)    { addToken(user, client, Time.now + 10.minutes) }
    let(:expired_token) { addToken(user, client, Time.now - 10.minutes) }
    context 'when sending the good bearer token' do
      let(:token){ good_token }
      it "should authenticate" do
        strategy.authenticate!.should eql :success
      end
    end
    context 'when sending the expired token' do
      let(:token){ expired_token }
      it "authentication should fail" do
        strategy.authenticate!.should eql :failure
      end
    end
  end

end
