require 'spec_helper'
require 'delorean'

# needed to generate signed portal tokens
ENV['JWT_HMAC_SECRET'] = 'foo'

describe JwtBearerTokenAuthenticatable::BearerToken do
  let(:strategy)      { JwtBearerTokenAuthenticatable::BearerToken.new(nil) }
  let(:request)       { double('request') }
  let(:mapping)       { Devise.mappings[:user] }
  let(:expires_in)    { 10.minutes.to_i }
  let(:token)         { SignedJWT.create_portal_token(user, {}, expires_in) }
  let(:decoded_token) { SignedJWT::decode_portal_token(token) }
  let(:headers)       { {"Authorization" => "Bearer/JWT #{token}"} }
  let(:user)          { FactoryGirl.create(:user) }
  let(:params)        { {} }
  before(:each) {
    allow(request).to receive(:headers).and_return(headers)
    allow(request).to receive(:params).and_return(params)
    allow(strategy).to receive(:mapping).and_return(mapping)
    allow(strategy).to receive(:request).and_return(request)
  }
  after(:each) {
    Delorean.back_to_the_present
  }

  context 'a user with a short-lived authentication token' do
    let(:expires_in) { 10.minutes.to_i }
    it 'should authenticate the user' do
      expect(strategy.authenticate!).to eql :success
    end

    it 'the token should expire 12 minutes into the future' do
      Delorean.jump(12 * 60) # move 12 minutes into the future
      expect(strategy.authenticate!).to eql :failure
    end

    it 'the token should have a uid set' do
      expect(decoded_token[:data]["uid"]).to eql user.id
    end
  end

  context 'a user with a valid authentication token with claims' do
    let(:token) { SignedJWT.create_portal_token(user, {bar: true, baz: 'bam'}, 10.minutes.to_i) }

    it 'should authenticate the user' do
      expect(strategy.authenticate!).to eql :success
    end

    it 'the token should have the claims embedded' do
      expect(decoded_token[:data]['bar']).to eql true
      expect(decoded_token[:data]['baz']).to eql 'bam'
    end
  end

  context 'a user with an expired authentication token' do
    let(:expires_in) { -10.minutes.to_i}
    it 'should NOT authenticate the user' do
      expect(strategy.authenticate!).to eql :failure
    end
  end

  context 'a user with one expired authentication token, and a valid token' do
    let(:good_token)    { SignedJWT.create_portal_token(user, {}, 10.minutes.to_i) }
    let(:expired_token) { SignedJWT.create_portal_token(user, {}, -10.minutes.to_i) }
    context 'when sending the good bearer token' do
      let(:token) { good_token }
      it "should authenticate" do
        expect(strategy.authenticate!).to eql :success
      end
    end
    context 'when sending the expired token' do
      let(:token){ expired_token }
      it "authentication should fail" do
        expect(strategy.authenticate!).to eql :failure
      end
    end
  end

end

