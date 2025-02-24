# frozen_string_literal: false
require 'spec_helper'

RSpec.describe API::APIController, type: :controller do

  def set_standard_bearer_token(auth_token)
    request.headers["Authorization"] = "Bearer #{auth_token}"
  end

  def set_jwt_bearer_token(auth_token)
    request.headers["Authorization"] = "Bearer/JWT #{auth_token}"
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

  describe '#check_for_auth_token' do
    it 'should fail without an authorization header or current_user' do
      expect { controller.check_for_auth_token({}) }.to raise_error('You must be logged in to use this endpoint')
    end

    describe 'with a current_user and no authorization header' do
      let(:user) { FactoryBot.create(:user) }

      before(:each) do
        allow(controller).to receive(:current_user).and_return(user)
      end

      it 'should return the current_user' do
        expect(controller.check_for_auth_token({})).to eq([user, nil])
      end
    end

    describe 'with an authorization header' do
      let(:expires)         { Time.now + 1000000000.minutes}
      let(:user_token)      { addToken(user, client, expires) }
      let(:user)            { FactoryBot.create(:user) }
      let(:url_for_user)    { "http://test.host/users/#{user.id}" } # can't use url_for(user) helper in specs
      let(:uid)             { Digest::MD5.hexdigest(url_for_user) }
      let(:learner_token)   { addTokenForLearner(user, client, learner, expires) }
      let(:teacher_token)   { addTokenForTeacher(user, client, class_teacher, expires) }
      let(:runnable)        { FactoryBot.create(:external_activity, runnable_opts)    }
      let(:offering)        { FactoryBot.create(:portal_offering, offering_opts)    }
      let(:clazz)           { FactoryBot.create(:portal_clazz, teachers: [class_teacher], students:[student], logging: true, class_hash: "test") }
      let(:offering_opts)   { {clazz: clazz, runnable: runnable}  }
      let(:runnable_opts)   { {name: 'the activity'}              }
      let(:class_teacher)   { FactoryBot.create(:portal_teacher)     }
      let(:student)         { FactoryBot.create(:full_portal_student) }
      let(:learner_key)     { "learner_key" }
      let(:learner)         { Portal::Learner.where(offering_id: offering.id, student_id: student.id, secure_key: learner_key ).first_or_create }
      let(:domain_matchers) { "http://x.y.z" }   # don't know why this is required
      let(:app_secret)      { "secret" }
      let(:client)          { Client.create(
             :name       => "test_api_client",
             :app_id     => "test_api_client",
             :app_secret => app_secret,
             :domain_matchers => domain_matchers
      )}

      describe 'using a standard bearer token' do

        it 'should fail with an invalid token' do
          set_standard_bearer_token('invalid')
          expect { controller.check_for_auth_token({}) }.to raise_error('Cannot find AccessGrant for requested token')
        end

        describe 'with an expired token that is an access grant' do
          let(:expires) { Time.now - 1.minutes }

          it 'should fail' do
            set_standard_bearer_token(user_token)
            expect { controller.check_for_auth_token({}) }.to raise_error('AccessGrant has expired')
          end
        end

        describe 'with a token that is not access grant' do
          before(:each) do
            set_standard_bearer_token(client.app_secret)
          end

          describe 'with a learner_id_or_key' do
            it 'should fail with an unknown learner' do
              expect { controller.check_for_auth_token({:learner_id_or_key => "invalid"}) }.to raise_error("Cannot find learner with id or key of 'invalid'")
            end
            it 'should fail with an unknown peer token' do
              set_standard_bearer_token("invalid_app_secret")
              expect { controller.check_for_auth_token({:learner_id_or_key => learner.id.to_s}) }.to raise_error("Cannot find requested peer token")
            end
            it 'should succeed with a valid peer token' do
              auth_user, auth_roles = controller.check_for_auth_token({:learner_id_or_key => learner.id.to_s})
              expect(auth_user).to eq(learner.student.user)
              expect(auth_roles).to eq({:learner => learner, :teacher => nil})
            end
          end

          describe 'with a user_id' do
            it 'should fail with an unknown user' do
              expect { controller.check_for_auth_token({:user_id => 10000000}) }.to raise_error("Cannot find user with id of '10000000'")
            end
            it 'should fail with an unknown peer token' do
              set_standard_bearer_token("invalid_app_secret")
              expect { controller.check_for_auth_token({:user_id => user.id}) }.to raise_error("Cannot find requested peer token")
            end
            it 'should succeed with a valid peer token' do
              auth_user, auth_roles = controller.check_for_auth_token({:user_id => user.id})
              expect(auth_user).to eq(user)
              expect(auth_roles).to eq({:learner => nil, :teacher => nil})
            end
          end
        end

        describe 'using a jwt bearer token' do
          let(:user)           { FactoryBot.create(:user) }
          let(:claims)         { {} }
          let(:expires)        { 3600 }
          let(:user_jwt_token) { SignedJwt.create_portal_token(user, claims, expires) }
          before(:each) {
            set_jwt_bearer_token(user_jwt_token)
          }

          it 'should fail with an invalid token' do
            set_standard_bearer_token('invalid')
            expect { controller.check_for_auth_token({}) }.to raise_error('Cannot find AccessGrant for requested token')
          end

          describe 'with an expired token' do
            let(:expires) { -1 }
            it 'should fail' do
              expect { controller.check_for_auth_token({}) }.to raise_error('Signature has expired')
            end
          end

          describe 'with a uid in the decoded jwt' do
            describe 'with an unknown user' do
              let(:user) {OpenStruct.new({id: 10000000})}
              it 'should fail' do
                expect { controller.check_for_auth_token({}) }.to raise_error('User in token not found')
              end
            end
            describe 'with an known user' do
              it 'should succeed' do
                auth_user, auth_roles = controller.check_for_auth_token({})
                expect(auth_user).to eq(user)
                expect(auth_roles).to eq({:learner => nil, :teacher => nil})
              end
            end
            describe 'with learner claims' do
              describe 'that are invalid' do
                let(:claims) { {"user_type" => "learner", "learner_id" => 10000000} }
                it 'should succeed but not have a learner role' do
                  auth_user, auth_roles = controller.check_for_auth_token({})
                  expect(auth_user).to eq(user)
                  expect(auth_roles).to eq({:learner => nil, :teacher => nil})
                end
              end
              describe 'that are valid' do
                let(:claims) { {"user_type" => "learner", "learner_id" => learner.id} }
                it 'should succeed' do
                  auth_user, auth_roles = controller.check_for_auth_token({})
                  expect(auth_user).to eq(user)
                  expect(auth_roles).to eq({:learner => learner, :teacher => nil})
                end
              end
            end
            describe 'with teacher claims' do
              describe 'that are invalid' do
                let(:claims) { {"user_type" => "teacher", "teacher_id" => 10000000} }
                it 'should succeed but now have a teacher role' do
                  auth_user, auth_roles = controller.check_for_auth_token({})
                  expect(auth_user).to eq(user)
                  expect(auth_roles).to eq({:learner => nil, :teacher => nil})
                end
              end
              describe 'that are valid' do
                let(:claims) { {"user_type" => "teacher", "teacher_id" => class_teacher.id} }
                it 'should succeed' do
                  auth_user, auth_roles = controller.check_for_auth_token({})
                  expect(auth_user).to eq(user)
                  expect(auth_roles).to eq({:learner => nil, :teacher => class_teacher})
                end
              end
            end
          end
        end
      end
    end
  end
end
