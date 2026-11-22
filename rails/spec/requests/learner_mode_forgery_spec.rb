require 'spec_helper'

# The switches are POST requests that need the form security token. Another website cannot get
# the token, so it cannot switch a signed-in teacher or create a learner account.
RSpec.describe 'Learner mode switches need a POST with the security token', type: :request do
  include Devise::Test::IntegrationHelpers
  # See learner_account_changes_spec.rb.
  before(:all) { Rails.application.reload_routes_unless_loaded }
  before(:each) { generate_default_settings_with_mocks }

  around(:each) do |example|
    old_value = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
    example.run
  ensure
    ActionController::Base.allow_forgery_protection = old_value
  end

  let(:teacher) { FactoryBot.create(:portal_teacher) }

  def signed_in_user_id
    session['warden.user.user.key']&.first&.first
  end

  def page_token
    get preferences_user_path(teacher.user)
    response.body[/name="authenticity_token" value="([^"]+)"/, 1].tap { |token| expect(token).to be_present }
  end

  before(:each) { sign_in teacher.user }

  it 'does not switch or create anything on a GET to the enter address' do
    expect { get '/learner_mode/enter' }.not_to change(User, :count)
    expect(response).to redirect_to('/learner_mode')
    expect(signed_in_user_id).to eq(teacher.user.id)
  end

  it 'does not switch back on a GET to the exit address' do
    learner_user = teacher.find_or_create_teacher_preview_student!
    sign_in learner_user
    get '/learner_mode/exit'
    expect(response).to redirect_to('/')
    expect(signed_in_user_id).to eq(learner_user.id)
  end

  it 'does not switch or create anything on a POST without the token' do
    get preferences_user_path(teacher.user)
    expect { post enter_learner_mode_path }.not_to change(User, :count)
    expect(teacher.reload.teacher_preview_student_id).to be_nil
    get preferences_user_path(teacher.user)
    expect(signed_in_user_id).to eq(teacher.user.id)
  end

  it 'switches on a POST with the token' do
    token = page_token
    expect { post enter_learner_mode_path, params: { authenticity_token: token } }.to change(User, :count).by(1)
    expect(signed_in_user_id).to eq(teacher.reload.teacher_preview_student.user_id)
  end
end
