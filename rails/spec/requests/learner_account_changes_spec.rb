require 'spec_helper'

# A teacher learner account must not get a login or password its teacher knows. These go through
# the real pages, because the refusals live in several controllers and policies.
RSpec.describe 'Changes to a teacher learner account', type: :request do
  include Devise::Test::IntegrationHelpers
  # Rails 8 draws routes lazily in test, and Devise registers its Warden strategies from
  # the routes' devise_for, so the first request of a process would otherwise be
  # authenticated without them.
  before(:all) { Rails.application.reload_routes_unless_loaded }

  let(:teacher)      { FactoryBot.create(:portal_teacher) }
  let(:learner_user) { teacher.find_or_create_teacher_learner! }
  let(:new_password) { 'a-new-password-1' }
  let(:password_params) do
    { user_reset_password: { password: new_password, password_confirmation: new_password }, commit: 'Save' }
  end

  def refused_with(message)
    expect(response).to have_http_status(:redirect)
    expect(flash['alert']).to start_with(message)
  end

  describe 'the learner account itself' do
    before(:each) { sign_in learner_user }

    it 'cannot update itself' do
      put user_path(learner_user), params: { user: { first_name: 'Changed', login: 'known-login' } }
      refused_with("You don't have permission")
      learner_user.reload
      expect(learner_user.first_name).not_to eq('Changed')
      expect(learner_user.login).not_to eq('known-login')
    end

    it 'cannot open the change password page at /change_password/0' do
      get change_password_path(reset_code: '0')
      refused_with("You don't have permission to change this password")
    end

    it 'cannot change its password through /change_password/0' do
      post '/passwords/update_users_password', params: password_params.merge(reset_code: '0')
      refused_with("You don't have permission to change this password")
      expect(learner_user.reload.valid_password?(new_password)).to be false
    end

    it 'cannot reset its password through users#reset_password' do
      expect {
        get reset_password_user_path(learner_user)
      }.not_to change(Password, :count)
      refused_with("You don't have permission")
    end

    it 'cannot edit its security questions' do
      get edit_user_security_questions_path(learner_user)
      refused_with("You don't have permission")
    end

    it 'cannot update its security questions' do
      put user_security_questions_path(learner_user), params: {
        security_questions: (0..2).to_h { |i| ["question#{i}", { question_idx: i.to_s, answer: "answer #{i}" }] }
      }
      refused_with("You don't have permission")
      expect(learner_user.reload.security_questions).to be_empty
    end
  end

  it 'a normal student can still change its own password through /change_password/0' do
    student_user = FactoryBot.create(:full_portal_student).user
    sign_in student_user
    post '/passwords/update_users_password', params: password_params.merge(reset_code: '0')
    expect(student_user.reload.valid_password?(new_password)).to be true
  end

  it 'the teacher of record cannot reset its password' do
    learner_user.portal_student.student_clazzes.create!(clazz: teacher.clazzes.first)
    sign_in teacher.user

    expect {
      get reset_password_user_path(learner_user)
    }.not_to change(Password, :count)
    refused_with("You don't have permission")
  end

  it 'an admin cannot reset its password' do
    sign_in FactoryBot.generate(:admin_user)

    expect {
      get reset_password_user_path(learner_user)
    }.not_to change(Password, :count)
    refused_with("You don't have permission")
  end

  describe 'an admin' do
    before(:each) { sign_in FactoryBot.generate(:admin_user) }

    it 'cannot update it' do
      put user_path(learner_user), params: { user: { first_name: 'Changed', login: 'known-login' } }
      refused_with("You don't have permission")
      learner_user.reload
      expect(learner_user.first_name).not_to eq('Changed')
      expect(learner_user.login).not_to eq('known-login')
    end

    it 'cannot open its edit page' do
      get edit_user_path(learner_user)
      refused_with("You don't have permission")
    end

    it 'cannot open its limited edit page' do
      get limited_edit_user_path(learner_user)
      refused_with("You don't have permission")
    end

    it 'cannot give it project researcher roles through limited_update' do
      project = FactoryBot.create(:project)
      admin_user = FactoryBot.generate(:admin_user)
      admin_user.add_role_for_project('admin', project)
      sign_in admin_user

      patch limited_update_user_path(learner_user), params: {
        user: { has_projects_in_form: '1', researcher_project_ids: [project.id.to_s] }
      }
      refused_with("You don't have permission")
      expect(learner_user.reload.researcher_for_projects).to be_empty
    end

    it 'can still view it' do
      get user_path(learner_user)
      expect(response).to have_http_status(:ok)
    end

    it 'can still edit a normal student' do
      student_user = FactoryBot.create(:full_portal_student).user
      put user_path(student_user), params: { user: { first_name: 'Changed' } }
      expect(student_user.reload.first_name).to eq('Changed')
    end
  end
end
