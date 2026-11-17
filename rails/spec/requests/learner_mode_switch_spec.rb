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
  let!(:learner_user) { teacher.find_or_create_teacher_learner! }

  it 'keeps the admin switch values through enter and exit, and Switch back still returns to the admin' do
    sign_in admin
    put switch_user_path(teacher_user), params: { commit: 'Switch' }
    expect(controller.current_user).to eq(teacher_user)
    expect(session[:original_user_id]).to eq(admin.id)

    get enter_learner_mode_path
    expect(controller.current_user).to eq(learner_user)
    expect(session[:original_user_id]).to eq(admin.id)
    expect(session[:recently_switched_from_users]).to eq([admin.id])

    get exit_learner_mode_path
    expect(controller.current_user).to eq(teacher_user)
    expect(session[:original_user_id]).to eq(admin.id)
    expect(session[:recently_switched_from_users]).to eq([admin.id])

    get switch_back_user_path(teacher_user)
    expect(controller.current_user).to eq(admin)
  end

  it 'does not set the admin switch values for a teacher who was not switched into' do
    sign_in teacher_user

    get enter_learner_mode_path
    expect(controller.current_user).to eq(learner_user)
    expect(session[:original_user_id]).to be_nil
    expect(session[:recently_switched_from_users]).to be_nil

    get exit_learner_mode_path
    expect(controller.current_user).to eq(teacher_user)
    expect(session[:original_user_id]).to be_nil
    expect(session[:recently_switched_from_users]).to be_nil
  end
end
