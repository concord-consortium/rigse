# encoding: utf-8
require 'spec_helper'
require 'digest/md5'

def set_auth_token(auth_token)
  request.headers["Authorization"] = "Bearer #{auth_token}"
end

def addToken(user, client, expires_at)
  grant = user.access_grants.create({
      :client => client,
      :state => nil,
      :access_token_expires_at => expires_at }
  )
  grant.access_token
end

def addTokenForLearner(user, client, learner, expires_at)
  grant = user.access_grants.create({
      :client => client,
      :state => nil,
      :learner => learner,
      :access_token_expires_at => expires_at }
  )
  grant.access_token
end

def addTokenForTeacher(user, client, teacher, expires_at)
  grant = user.access_grants.create({
      :client => client,
      :state => nil,
      :teacher => teacher,
      :access_token_expires_at => expires_at }
  )
  grant.access_token
end

describe API::V1::JwtController, :type => :controller do

  let(:expires)         { Time.now + 1000000000.minutes}
  let(:user_token)      { addToken(user, client, expires) }
  let(:user)            { FactoryBot.create(:user) }
  let(:url_for_user)    { "http://test.host/users/#{user.id}" } # can't use url_for(user) helper in specs
  let(:uid)             { Digest::MD5.hexdigest(url_for_user) }
  let(:learner_token)   { addTokenForLearner(user, client, learner, expires) }
  let(:teacher_token)   { addTokenForTeacher(user, client, class_teacher, expires) }
  let(:runnable)        { FactoryBot.create(:activity, runnable_opts)    }
  let(:offering)        { FactoryBot.create(:portal_offering, offering_opts)    }
  let(:clazz)           { FactoryBot.create(:portal_clazz, teachers: [class_teacher], students:[student], logging: true, class_hash: "test") }
  let(:offering_opts)   { {clazz: clazz, runnable: runnable}  }
  let(:runnable_opts)   { {name: 'the activity'}              }
  let(:class_teacher)   { FactoryBot.create(:portal_teacher)     }
  let(:student)         { FactoryBot.create(:full_portal_student) }
  let(:learner)         { Portal::Learner.where(offering_id: offering.id, student_id: student.id ).first_or_create }
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

  let(:site_url) { "http://test.host/" }

  before(:each) {
    # prevent warnings about undefined default settings
    generate_default_settings_and_jnlps_with_mocks

    allow(APP_CONFIG).to receive(:[]).and_call_original
    allow(APP_CONFIG).to receive(:[]).with(:site_url).and_return(site_url)
  }

  describe "GET #firebase" do

    context "when a invalid authentication header token is sent" do
      before(:each) {
        set_auth_token('invalid_token')
        FirebaseApp.create!(firebase_app_attributes)
      }

      it "returns 400" do
        post :firebase, {:firebase_app => "test app"}, :format => :json
        expect(response.status).to eq(400)
      end
    end

    def decode_token
      expect(response.status).to eq(201)

      body = JSON.parse(response.body)
      token = body["token"]
      SignedJWT::decode_firebase_token(token, firebase_app_name)
    end

    shared_examples "valid learner jwt" do
      it "returns a valid JWT with learner params" do
        decoded_token = decode_token()
        expect(decoded_token[:data]).to include(
          "uid" => uid,
          "domain" => root_url,
          "externalId" => learner.id,
          "returnUrl" => be_present,
          "logging" => true,
          "domain_uid" => user.id,
          "class_info_url"  => be_present
        )
        expect(decoded_token[:data]["claims"]).to include(
          "user_type" => "learner",
          "user_id" => url_for_user,
          "class_hash" => be_present,
          "offering_id" => offering.id
        )
      end
    end


    context "when a valid authentication header token is sent" do
      context "and the token itself has no learner or teacher" do
        before(:each) {
          set_auth_token(user_token)
          FirebaseApp.create!(firebase_app_attributes)
        }

        context "and a firebase_app param is not sent" do
          it "returns 400" do
            post :firebase, {}, :format => :json
            expect(response.status).to eq(400)
          end
        end

        context "and an invalid firebase_app param is sent" do
          it "returns 500" do
            post :firebase, {:firebase_app => "invalid app"}, :format => :json
            expect(response.status).to eq(500)
          end
        end

        context "and a firebase_app param is sent" do
          shared_examples "valid user jwt" do
            it "returns a valid JWT" do
              decoded_token = decode_token()
              expect(decoded_token[:data]).to include(
                  "uid" => uid,
                )
              expect(decoded_token[:data]["claims"]).to include(
                "user_type" => "user",
                "user_id" => url_for_user,
                "platform_id" => site_url,
                "platform_user_id" => user.id
              )
            end
          end

          before(:each){
            post :firebase,
              { :firebase_app => "test app" },
              :format => :json
          }

          it_behaves_like "valid user jwt"

          context "and the site_url differs from the request domain" do
            let(:site_url)        { "http://canonical.host/"}
            let(:url_for_user)    { "#{site_url}users/#{user.id}" } # can't use url_for(user) helper in specs

            it_behaves_like "valid user jwt"
          end
        end

        context "and firebase_app and resource_link_id params are sent" do
          context "and the user of the auth header token has a learner with that resource_link_id" do
            let(:user) { learner.student.user }
            before(:each) {
              post :firebase,
                { :firebase_app => "test app", :resource_link_id => offering.id.to_s },
                :format => :json
            }
            it_behaves_like "valid learner jwt"

            context "and the site_url differs from the request domain" do
              let(:site_url)        { "http://canonical.host/"}
              let(:url_for_user)    { "http://canonical.host/users/#{user.id}" } # can't use url_for(user) helper in specs

              it_behaves_like "valid learner jwt"
            end
          end

          context "and the user of the auth header token has a teacher" do
            let(:user) { class_teacher.user }
            context "with a class with that resource_link_id" do
              shared_examples "valid teacher jwt" do
                it "returns a valid JWT with teacher params, and a class_hash claim" do
                  decoded_token = decode_token()
                  expect(decoded_token[:data]).to include(
                    "uid" => uid,
                    "domain_uid" => user.id,
                    "domain" => root_url
                  )
                  expect(decoded_token[:data]["claims"]).to include(
                    "user_type" => "teacher",
                    "user_id" => url_for_user,
                    "platform_id" => site_url,
                    "class_hash" => be_present
                  )

                  # Even though we send in an resource_link_id the claims in this JWT are
                  # Valid for any offering in the class not just the offering of this resource_link_id
                  # This approach is for consitancy with other ways of getting teacher JWTs
                  expect(decoded_token[:data]["claims"]).to_not include(
                    "offering_id" => be_present
                  )
                end
              end

              before(:each){
                post :firebase,
                  { :firebase_app => "test app", :resource_link_id => offering.id.to_s },
                  :format => :json
              }


              it_behaves_like "valid teacher jwt"

              context "and the site_url differs from the request domain" do
                let(:site_url)        { "http://canonical.host/"}
                let(:url_for_user)    { "http://canonical.host/users/#{user.id}" } # can't use url_for(user) helper in specs

                it_behaves_like "valid teacher jwt"
              end
            end
            context "without a class with that resource_link_id" do
              it "returns a 400" do
                post :firebase,
                  {:firebase_app => "test app", :resource_link_id => 9999.to_s},
                  :format => :json
                expect(response.status).to eq(400)
              end
            end
          end
          context "and the user of the auth header token is not a teacher or student" do
            it "returns a 400" do
              post :firebase,
                {:firebase_app => "test app", :resource_link_id => offering.id.to_s},
                :format => :json
              expect(response.status).to eq(400)
            end
          end
        end
      end

      context "and the token has a learner" do
        before(:each) {
          set_auth_token(learner_token)
          FirebaseApp.create!(firebase_app_attributes)

          post :firebase, {:firebase_app => "test app"}, :format => :json
        }

        it_behaves_like "valid learner jwt"
      end

      context "and the token has a teacher" do
        before(:each) {
          set_auth_token(teacher_token)
          FirebaseApp.create!(firebase_app_attributes)
        }

        context "and there is no class hash" do
          shared_examples "valid teacher jwt" do
            it "returns a valid JWT" do
              post :firebase, {:firebase_app => "test app"}, :format => :json
              decoded_token = decode_token()

              expect(decoded_token[:data]).to include(
                  "uid" => uid,
                  "domain" => root_url
                )

              expect(decoded_token[:data]["claims"]).to include(
                "user_type" => "teacher",
                "user_id" => url_for_user,
                "class_hash" => be_nil,
                "platform_id" => site_url
              )
            end
          end

          it_behaves_like "valid teacher jwt"

          context "and the site_url differs from the request domain" do
            let(:site_url)        { "http://canonical.host/"}
            let(:url_for_user)    { "http://canonical.host/users/#{user.id}" } # can't use url_for(user) helper in specs

            it_behaves_like "valid teacher jwt"
          end

        end

        context "and there is a class hash" do
          context "and the class hash is invalid" do
            it "returns 400" do
              post :firebase, {:firebase_app => "test app", :class_hash => "invalid"}, :format => :json
              expect(response.status).to eq(400)
            end
          end

          context "and the class_hash is for a class of the teacher" do
            it "returns a valid JWT with this class hash" do
              post :firebase, {:firebase_app => "test app", :class_hash => clazz.class_hash}, :format => :json
              decoded_token = decode_token()

              expect(decoded_token[:data]["claims"]).to include(
                "class_hash" => clazz.class_hash
              )
            end
          end
        end
      end
    end
  end

  describe "GET #portal" do
    context "when a invalid authentication header token is sent" do
      before(:each) {
        set_auth_token('invalid_token')
      }

      it "returns 400" do
        post :portal, {}, :format => :json
        expect(response.status).to eq(400)
      end
    end

    context "when a valid authentication header token is sent" do

      context "and the token has no learner or teacher" do
        before(:each) {
          set_auth_token(user_token)
        }

        context "and a JWT_HMAC_SECRET is not set" do
          it "returns 500" do
            allow(ENV).to receive(:[]).and_call_original
            allow(ENV).to receive(:[]).with('JWT_HMAC_SECRET').and_return(nil)
            post :portal, {}, :format => :json
            expect(response.status).to eq(500)
          end
        end

        it "returns a valid JWT" do
          post :portal, {}, :format => :json
          expect(response.status).to eq(201)

          body = JSON.parse(response.body)
          token = body["token"]
          decoded_token = SignedJWT::decode_portal_token(token)
          expect(decoded_token[:data]["uid"]).to eql user.id
        end

        context "and a resource_link_id is sent" do
          context "and the user of the token has a learner with that resource_link_id" do
            let(:user) { learner.student.user }
            it "returns a valid JWT with learner params" do
              post :portal, {:resource_link_id => offering.id}, :format => :json
              expect(response.status).to eq(201)

              body = JSON.parse(response.body)
              token = body["token"]
              decoded_token = SignedJWT::decode_portal_token(token)

              expect(decoded_token[:data]["uid"]).to eql user.id
              expect(decoded_token[:data]["domain"]).to eql root_url
              expect(decoded_token[:data]["user_type"]).to eq "learner"
              expect(decoded_token[:data]["user_id"]).not_to be_nil
              expect(decoded_token[:data]["learner_id"]).to eq learner.id
              expect(decoded_token[:data]["class_info_url"]).not_to be_nil
              expect(decoded_token[:data]["offering_id"]).to eq offering.id
            end
          end
          context "and the user of the token has a learner without that resource_link_id" do
            let(:user) { learner.student.user }
            it "returns a 400" do
              post :portal, {:resource_link_id => 99999}, :format => :json
              expect(response.status).to eq(400)
            end
          end
          context "and the user of the token is not a student" do
            it "returns a 400" do
              post :portal, {:resource_link_id => offering.id}, :format => :json
              expect(response.status).to eq(400)
            end
          end
        end
      end

      context "and the token has a learner" do
        before(:each) {
          set_auth_token(learner_token)
        }

        it "returns a valid JWT with learner params" do
          post :portal, {}, :format => :json
          expect(response.status).to eq(201)

          body = JSON.parse(response.body)
          token = body["token"]
          decoded_token = SignedJWT::decode_portal_token(token)

          expect(decoded_token[:data]["uid"]).to eql user.id
          expect(decoded_token[:data]["domain"]).to eql root_url
          expect(decoded_token[:data]["user_type"]).to eq "learner"
          expect(decoded_token[:data]["user_id"]).not_to be_nil
          expect(decoded_token[:data]["learner_id"]).to eq learner.id
          expect(decoded_token[:data]["class_info_url"]).not_to be_nil
          expect(decoded_token[:data]["offering_id"]).to eq offering.id
        end
      end

      context "and the token has a teacher" do
        before(:each) {
          set_auth_token(teacher_token)
        }

        it "returns a valid JWT with teacher params without a class hash" do
          post :portal, {}, :format => :json
          expect(response.status).to eq(201)

          body = JSON.parse(response.body)
          token = body["token"]
          decoded_token = SignedJWT::decode_portal_token(token)

          expect(decoded_token[:data]["uid"]).to eql user.id
          expect(decoded_token[:data]["domain"]).to eql root_url
          expect(decoded_token[:data]["user_type"]).to eq "teacher"
          expect(decoded_token[:data]["user_id"]).not_to be_nil
          expect(decoded_token[:data]["teacher_id"]).to eq class_teacher.id
          expect(decoded_token[:data]["admin"]).to eq -1
        end

        context "and the user is an admin" do
          before(:each) {
            user.add_role("admin")
          }

          it "returns a valid JWT with an admin flag set" do
            post :portal, {}, :format => :json
            expect(response.status).to eq(201)

            body = JSON.parse(response.body)
            token = body["token"]
            decoded_token = SignedJWT::decode_portal_token(token)

            expect(decoded_token[:data]["admin"]).to eql 1
            expect(decoded_token[:data]["project_admins"]).to eql []
          end
        end

        context "and the user is a project admin" do
          let(:project)         { FactoryBot.create(:project)}
          before(:each) {
            user.project_users.create({project_id: project.id, is_admin: true})
          }

          it "returns a valid JWT with the project in project_admins claim and admin is -1" do
            post :portal, {}, :format => :json
            expect(response.status).to eq(201)

            body = JSON.parse(response.body)
            token = body["token"]
            decoded_token = SignedJWT::decode_portal_token(token)

            expect(decoded_token[:data]["admin"]).to eql -1
            expect(decoded_token[:data]["project_admins"]).to eql [project.id]
          end
        end
      end
    end
  end
end
