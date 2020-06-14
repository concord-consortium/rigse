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

def addTokenForLearner(user, client, learner, expires_at)
  grant = user.access_grants.create({
      :client => client,
      :state => nil,
      :learner => learner,
      :access_token_expires_at => expires_at },
    :without_protection => true
  )
  grant.access_token
end

def addTokenForTeacher(user, client, teacher, expires_at)
  grant = user.access_grants.create({
      :client => client,
      :state => nil,
      :teacher => teacher,
      :access_token_expires_at => expires_at },
    :without_protection => true
  )
  grant.access_token
end

describe BearerTokenAuthenticatable::BearerToken do
  after(:each) { Delorean.back_to_the_present }
  let(:domain_matchers) { "" }
  let(:strategy)        { BearerTokenAuthenticatable::BearerToken.new(nil) }
  let(:request)         { double('request') }
  let(:mapping)         { Devise.mappings[:user] }
  let(:expires)         { Time.now + 10.minutes}
  let(:user_token)      { addToken(user, client, expires) }
  let(:user_headers)    { {"Authorization" => "Bearer #{user_token}"} }
  let(:learner_token)   { addTokenForLearner(user, client, learner, expires) }
  let(:teacher_token)   { addTokenForTeacher(user, client, class_teacher, expires) }
  let(:learner_headers) { {"Authorization" => "Bearer #{learner_token}"} }
  let(:teacher_headers) { {"Authorization" => "Bearer #{teacher_token}"} }
  let(:user)            { FactoryBot.create(:user) }
  let(:runnable)        { FactoryBot.create(:activity, runnable_opts)    }
  let(:offering)        { FactoryBot.create(:portal_offering, offering_opts)    }
  let(:clazz)           { FactoryBot.create(:portal_clazz, teachers: [class_teacher], students:[student]) }
  let(:offering_opts)   { {clazz: clazz, runnable: runnable}  }
  let(:runnable_opts)   { {name: 'the activity'}              }
  let(:class_teacher)   { FactoryBot.create(:portal_teacher)     }
  let(:student)         { FactoryBot.create(:full_portal_student) }
  let(:learner)         { Portal::Learner.where(offering_id: offering.id, student_id: student.id).first_or_create }
  let(:params)          { {} }
  let(:client)          { Client.create(
         :name       => "test_api_client",
         :app_id     => "test_api_client",
         :app_secret => SecureRandom.uuid,
         :domain_matchers => domain_matchers
  )}
  let(:referrer)  { "https://foo.bar.com/some/path.html" }
  before(:each) {
    allow(request).to receive(:headers).and_return(user_headers)
    allow(request).to receive(:env).and_return({'HTTP_REFERER' => referrer})
    allow(request).to receive(:params).and_return(params)
    allow(strategy).to receive(:mapping).and_return(mapping)
    allow(strategy).to receive(:request).and_return(request)
  }

  context 'a user with a short-lived authentication token' do
    let(:expires) { Time.now + 10.minutes}
    it 'should authenticate the user' do
      expect(strategy.authenticate!).to eql :success
    end

    it 'the token should expire 12 minutes into the futre' do
      Delorean.jump(12 * 60) # move 12 minutes into the future
      expect(strategy.authenticate!).to eql :failure
    end
    context "from an allowed domain" do
      let(:domain_matchers) { "foo.bar.com" }
      it 'should authenticate the user' do
        expect(strategy.authenticate!).to eql :success
      end
    end
    context "from a prohibited domain" do
      let(:domain_matchers) { "bar.com" } #no foo
      it 'should not authenticate the user' do
        expect(strategy.authenticate!).to eql :failure
      end
    end
  end

  context 'a user with an expired authentication token' do
    let(:expires) { Time.now - 10.minutes}
    it 'should NOT authenticate the user' do
      expect(strategy.authenticate!).to eql :failure
    end
  end

  context 'a user with one expired authentication token, and a valid token' do
    let(:good_token)    { addToken(user, client, Time.now + 10.minutes) }
    let(:expired_token) { addToken(user, client, Time.now - 10.minutes) }
    context 'when sending the good bearer token' do
      let(:user_token){ good_token }
      it "should authenticate" do
        expect(strategy.authenticate!).to eql :success
      end
    end
    context 'when sending the expired token' do
      let(:user_token){ expired_token }
      it "authentication should fail" do
        expect(strategy.authenticate!).to eql :failure
      end
    end
  end

  context 'a learner with a short-lived authentication token' do
    before(:each) {
      allow(request).to receive(:headers).and_return(learner_headers)
    }

    let(:expires) { Time.now + 10.minutes}
    it 'should authenticate the learner' do
      expect(strategy.authenticate!).to eql :success
    end

    it 'should be able to get the learner from the token' do
      grant = AccessGrant.find_by_access_token(learner_token)
      expect(grant.learner).to eql learner
    end
  end

  context 'a teacher with a short-lived authentication token' do
    before(:each) {
      allow(request).to receive(:headers).and_return(teacher_headers)
    }

    let(:expires) { Time.now + 10.minutes}
    it 'should authenticate the teacher' do
      expect(strategy.authenticate!).to eql :success
    end

    it 'should be able to get the teacher from the token' do
      grant = AccessGrant.find_by_access_token(teacher_token)
      expect(grant.teacher).to eql class_teacher
    end
  end
end
