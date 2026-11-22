require 'spec_helper'

# The admin switch values in the session must survive learner mode. Controller specs cannot show
# this, because Devise's controller test helpers never clear the session on sign_out. A request
# spec runs the real Warden sign-out and sign-in.
RSpec.describe 'Learner mode after an admin switch', type: :request do
  include Devise::Test::IntegrationHelpers
  # Rails 8 draws routes lazily in test, and Devise registers its Warden strategies from
  # the routes' devise_for, so the first request of a process would otherwise be
  # authenticated without them.
  before(:all) { Rails.application.reload_routes_unless_loaded }

  let(:admin)        { FactoryBot.generate(:admin_user) }
  let(:teacher)      { FactoryBot.create(:portal_teacher) }
  let(:teacher_user) { teacher.user }
  let!(:learner_user) { teacher.find_or_create_teacher_preview_student! }

  it 'keeps the admin switch values through enter and exit, and Switch back still returns to the admin' do
    sign_in admin
    put switch_user_path(teacher_user), params: { commit: 'Switch' }
    expect(controller.current_user).to eq(teacher_user)
    expect(session[:original_user_id]).to eq(admin.id)

    post enter_learner_mode_path
    expect(controller.current_user).to eq(learner_user)
    expect(session[:original_user_id]).to eq(admin.id)
    expect(session[:recently_switched_from_users]).to eq([admin.id])

    post exit_learner_mode_path
    expect(controller.current_user).to eq(teacher_user)
    expect(session[:original_user_id]).to eq(admin.id)
    expect(session[:recently_switched_from_users]).to eq([admin.id])

    post switch_back_user_path(teacher_user)
    expect(controller.current_user).to eq(admin)
  end

  # In learner mode, the sidebar shows both "Switch back" and "Switch back to teacher".
  it 'switches back to the admin straight from learner mode' do
    sign_in admin
    put switch_user_path(teacher_user), params: { commit: 'Switch' }
    post enter_learner_mode_path
    expect(controller.current_user).to eq(learner_user)

    post switch_back_user_path(learner_user)
    expect(controller.current_user).to eq(admin)
  end

  it 'does not set the admin switch values for a teacher who was not switched into' do
    sign_in teacher_user

    post enter_learner_mode_path
    expect(controller.current_user).to eq(learner_user)
    expect(session[:original_user_id]).to be_nil
    expect(session[:recently_switched_from_users]).to be_nil

    post exit_learner_mode_path
    expect(controller.current_user).to eq(teacher_user)
    expect(session[:original_user_id]).to be_nil
    expect(session[:recently_switched_from_users]).to be_nil
  end

  it 'does not switch back to the admin on a GET' do
    sign_in admin
    put switch_user_path(teacher_user), params: { commit: 'Switch' }
    expect(controller.current_user).to eq(teacher_user)

    get switch_back_user_path(teacher_user)
    expect(response).to redirect_to('/')
    get preferences_user_path(teacher_user)
    expect(controller.current_user).to eq(teacher_user)
  end

  # A learner account can join classes outside its teacher's cohorts. A project admin for one of
  # those cohorts must not be able to switch to the learner account. If they could, "Switch back
  # to teacher" would sign them in as a teacher they can't switch to.
  it 'does not let a project admin switch to a learner account whose teacher is outside their cohorts' do
    cohort = FactoryBot.create(:admin_cohort)
    project = FactoryBot.create(:project, cohorts: [cohort])
    other_teacher = FactoryBot.create(:portal_teacher, cohorts: [cohort])
    learner_user.portal_student.student_clazzes.create!(clazz: other_teacher.clazzes.first)
    project_admin = FactoryBot.create(:confirmed_user)
    project_admin.add_role_for_project('admin', project)

    sign_in project_admin
    put switch_user_path(learner_user), params: { commit: 'Switch' }
    expect(controller.current_user).to eq(project_admin)

    post exit_learner_mode_path
    expect(controller.current_user).to eq(project_admin)
  end
end
