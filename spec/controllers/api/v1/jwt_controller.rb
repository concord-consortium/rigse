# encoding: utf-8
require 'spec_helper'
require 'digest/md5'

def set_auth_token(auth_token)
  request.env["Authorization"] = "Bearer #{auth_token}"
end

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

describe API::V1::JwtController, :type => :controller do

  let(:expires)         { Time.now + 1000000000.minutes}
  let(:user_token)      { addToken(user, client, expires) }
  let(:user)            { FactoryGirl.create(:user) }
  let(:url_for_user)    { "http://test.host/users/#{user.id}" } # can't use url_for(user) helper in specs
  let(:uid)             { Digest::MD5.hexdigest(url_for_user) }
  let(:learner_token)   { addTokenForLearner(user, client, learner, expires) }
  let(:teacher_token)   { addTokenForTeacher(user, client, class_teacher, expires) }
  let(:runnable)        { Factory.create(:activity, runnable_opts)    }
  let(:offering)        { Factory(:portal_offering, offering_opts)    }
  let(:clazz)           { Factory(:portal_clazz, teachers: [class_teacher], students:[student], logging: true, class_hash: "test") }
  let(:offering_opts)   { {clazz: clazz, runnable: runnable}  }
  let(:runnable_opts)   { {name: 'the activity'}              }
  let(:class_teacher)   { Factory.create(:portal_teacher)     }
  let(:student)         { FactoryGirl.create(:full_portal_student) }
  let(:learner)         { Portal::Learner.find_or_create_by_offering_id_and_student_id(offering.id, student.id )}
  let(:domain_matchers) { "http://x.y.z" }   # don't know why this is required
  let(:client)          { Client.create(
         :name       => "test_api_client",
         :app_id     => "test_api_client",
         :app_secret => SecureRandom.uuid,
         :domain_matchers => domain_matchers
  )}
  let(:firebase_app_name)      { "test app" }
  let(:firebase_app_attributes) {{
          :name         =>  firebase_app_name,
          :client_email =>  "user@example.com",
          # note: the private key below is just a random key - it is not used anywhere
          :private_key  => "-----BEGIN RSA PRIVATE KEY-----
MIIEoQIBAAKCAQEAvdCMEYgVdmohS2w7yqPDxQhwKkK+15zDvOY1LgJNnLPoxxEP
uqQ++BHbfEaGp0jDsLG/f+CjKY2dCP+EHxOuyaAA0IV6eF5rMX0sz8EythpgZDLd
3mZnChBmP8EQYVAKvY9c8BTvYJFpuFkacxNzCJNop+PGXGlh5hl4FKC7AjF3KvQj
JHYhh9rE+DX58eQTs+vjjAq65/6+ep8GeDu644sn9HkjrQRvUiQgZhSOsNFl/01O
chGxLWlFrLO+YdyPlNHRhlEwonr+yI+BvtUoOfrFCstgcY8vvvApplx+efp5Cd4S
tGUwdn+zqFieeIKz8hUeM6xE2KX1+kXPd6MA+wIDAQABAoIBAGWQgFIlKa7JzPTp
ffjItcjo4fOK8Ui3ZfjeiRgMPXEaxvQ1SeBJYDQmgfW2WviJs8QI5/nJviRO1Pbq
mcxzILRb+/OXaFed1eeOHfswWi0cYfVbTmJhEsNM0RlN+bDIPmb9nfIMkaVvSU1N
yBxJDOVK0tX6x7nM3YhcmmcXNdlOqJX/8YTK6nuNzw2wHkl+RErvO+KycWMitDCx
ra6ygcgYf30JisilaQ5CvhhCbFx1I8tdep9ppy+JlaMU4q40PcVda5uKzW9ASF0u
LGjtW4Q95bPZDuy018nedK0noonxkqFgJ759ir6sW9xkRm3IJHyxS9ZmQ/t3Q1aC
MKUtfOkCgYEA3pSNyQ+d8KYh/8Jywi3ygU7JGeme3MPPDREI7/DmWNyvWABrW4Jc
bkSX8kHzNvYb+cn/DcOKZq5sB1oujLp6kTz0IxL++bUoDoEd/3dMN52l+qvf+I9K
wAXNwiWSNGoDbDeGiqJcn7/8oog7jlyKWspqEQnT7usnxFfp9iIsFJ8CgYEA2lCP
qRoXGl8Wfp6jOINLm6/X6r3rUsCWZhIBYp32jkFGEGdkJzcd0Za1ERI/fQrGW4m1
ujQZqkgzu1A7QhYQORHega9r7wh/b9HF50sIkWcnGShYG+0D3I7t9HP50ujmd4X7
c6stYubj8Ci4N74CzONTAXw016f8Igrb35ZoOiUCf3jaMCH7WMZRbiRwb97/E60i
Gg73ykoUB1gQ58lgA7I8IPinQaNuJMG6fMYNCQHOn2IBS3stsPgPvJhBXwUKO4Kg
le51YfwzYIx/jsom/Ds2Xei9ad6L7wpUHGROAhRze2hGvcaIYcJbe9DEJ5IkrPqe
7PhTXb9b7zusgFwkMcsCgYEAsKNyOV5Uxw+cwcJVSgphiIxUZShZWNFeXyO+Xy50
KVGDAQ7GqDweMlCAHFnpaKDpMXNQyGITSgW1ZZ9a8vOrGKHuqHtpFzSG99CBEc1S
F2Og7OgJsj6pWzGCMsILpqyunJKZi1M7G8S5NL2dn+xrk59yr8bxcnQGuvySPmwR
1MkCgYATo5WUro9o1XgEFVMjpwnzxFRED6n9yE13IcL8WH4mbmoVS7fg805A6Vci
RseUb0vhcp7NWNl86Tm7zWQW8B4RRDNJX4HiKAVzy55x8Azss1P8dPyf4I3c9hNw
SHlL1Ceaqm35aMguGMBcTs6T5jRJ36K2OPEXU2ZOiRygxcZhFw==
-----END RSA PRIVATE KEY-----"
        } }

  describe "GET #firebase" do

    context "when a valid authentication header token is sent without a learner or teacher" do
      before(:each) {
        set_auth_token(user_token)
        FirebaseApp.create!(firebase_app_attributes)
      }

      it "returns a valid JWT" do
        get :firebase, {:firebase_app => "test app"}, :format => :json
        expect(response.status).to eq(201)

        body = JSON.parse(response.body)
        token = body["token"]
        decoded_token = SignedJWT::decode_firebase_token(token, firebase_app_name)
        decoded_token[:data]["uid"].should eql uid
      end
    end

    context "when a valid authentication header token is sent with a learner" do
      before(:each) {
        set_auth_token(learner_token)
        FirebaseApp.create!(firebase_app_attributes)
      }

      it "returns a valid JWT with learner params" do
        get :firebase, {:firebase_app => "test app"}, :format => :json
        expect(response.status).to eq(201)

        body = JSON.parse(response.body)
        token = body["token"]
        decoded_token = SignedJWT::decode_firebase_token(token, firebase_app_name)

        decoded_token[:data]["uid"].should eql uid
        decoded_token[:data]["domain"].should eql root_url
        decoded_token[:data]["externalId"].should eql learner.id
        decoded_token[:data]["returnUrl"].should_not be_nil
        decoded_token[:data]["logging"].should eql true
        decoded_token[:data]["domain_uid"].should eql user.id
        decoded_token[:data]["class_info_url"].should_not be_nil
        decoded_token[:data]["claims"]["user_type"].should eq "learner"
        decoded_token[:data]["claims"]["user_id"].should eq url_for_user
        decoded_token[:data]["claims"]["class_hash"].should_not be_nil
        decoded_token[:data]["claims"]["offering_id"].should eq offering.id
      end
    end

    context "when a valid authentication header token is sent with a teacher" do
      before(:each) {
        set_auth_token(teacher_token)
        FirebaseApp.create!(firebase_app_attributes)
      }

      it "returns a valid JWT with teacher params without a class hash" do
        get :firebase, {:firebase_app => "test app"}, :format => :json
        expect(response.status).to eq(201)

        body = JSON.parse(response.body)
        token = body["token"]
        decoded_token = SignedJWT::decode_firebase_token(token, firebase_app_name)

        decoded_token[:data]["uid"].should eql uid
        decoded_token[:data]["domain"].should eql root_url
        decoded_token[:data]["claims"]["user_type"].should eq "teacher"
        decoded_token[:data]["claims"]["user_id"].should eq url_for_user
        decoded_token[:data]["claims"]["class_hash"].should eq nil
      end

      it "returns a valid JWT with teacher params with a class hash" do
        get :firebase, {:firebase_app => "test app", :class_hash => clazz.class_hash}, :format => :json
        expect(response.status).to eq(201)

        body = JSON.parse(response.body)
        token = body["token"]
        decoded_token = SignedJWT::decode_firebase_token(token, firebase_app_name)

        decoded_token[:data]["claims"]["class_hash"].should eq clazz.class_hash
      end
    end
  end

  describe "GET #portal"
  context "when a valid authentication header token is sent without a learner or teacher" do
    before(:each) {
      set_auth_token(user_token)
    }

    it "returns a valid JWT" do
      get :portal, {}, :format => :json
      expect(response.status).to eq(201)

      body = JSON.parse(response.body)
      token = body["token"]
      decoded_token = SignedJWT::decode_portal_token(token)
      decoded_token[:data]["uid"].should eql user.id
    end
  end

  context "when a valid authentication header token is sent with a learner" do
    before(:each) {
      set_auth_token(learner_token)
    }

    it "returns a valid JWT with learner params" do
      get :portal, {}, :format => :json
      expect(response.status).to eq(201)

      body = JSON.parse(response.body)
      token = body["token"]
      decoded_token = SignedJWT::decode_portal_token(token)

      decoded_token[:data]["uid"].should eql user.id
      decoded_token[:data]["domain"].should eql root_url
      decoded_token[:data]["user_type"].should eq "learner"
      decoded_token[:data]["user_id"].should_not be_nil
      decoded_token[:data]["learner_id"].should eq learner.id
      decoded_token[:data]["class_info_url"].should_not be_nil
      decoded_token[:data]["offering_id"].should eq offering.id
    end
  end

  context "when a valid authentication header token is sent with a teacher" do
    before(:each) {
      set_auth_token(teacher_token)
    }

    it "returns a valid JWT with teacher params without a class hash" do
      get :portal, {}, :format => :json
      expect(response.status).to eq(201)

      body = JSON.parse(response.body)
      token = body["token"]
      decoded_token = SignedJWT::decode_portal_token(token)

      decoded_token[:data]["uid"].should eql user.id
      decoded_token[:data]["domain"].should eql root_url
      decoded_token[:data]["user_type"].should eq "teacher"
      decoded_token[:data]["user_id"].should_not be_nil
      decoded_token[:data]["teacher_id"].should eq class_teacher.id
    end
  end
end
