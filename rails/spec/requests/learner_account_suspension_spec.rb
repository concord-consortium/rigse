require 'spec_helper'

# When a teacher is suspended or deleted, their teacher preview student account stops working too,
# and they cannot switch back to the teacher account.
RSpec.describe 'A teacher preview student account when its teacher is suspended or deleted', type: :request do
  include Devise::Test::IntegrationHelpers
  # See learner_account_changes_spec.rb.
  before(:all) { Rails.application.reload_routes_unless_loaded }
  before(:each) { generate_default_settings_with_mocks }

  # A refused request redirects back to the page it came from.
  let(:referer)      { { 'HTTP_REFERER' => 'http://www.example.com/' } }
  let(:teacher)      { FactoryBot.create(:portal_teacher) }
  let(:learner_user) { teacher.reload.teacher_preview_student.user }

  before(:each) do
    sign_in teacher.user
    post enter_learner_mode_path
  end

  def signed_in_user_id
    session['warden.user.user.key']&.first&.first
  end

  it 'keeps working while the teacher is active' do
    get preferences_user_path(learner_user), headers: referer
    expect(response).to have_http_status(:ok)
    expect(signed_in_user_id).to eq(learner_user.id)
  end

  it 'signs the learner account out on its next request after the teacher is suspended' do
    teacher.user.suspend!
    get preferences_user_path(learner_user), headers: referer
    expect(signed_in_user_id).to be_nil
    expect(flash['alert']).to eq('You cannot login since your account has been suspended.')
  end

  it 'signs the learner account out on its next request after the teacher is deleted' do
    teacher.user.delete!
    get preferences_user_path(learner_user), headers: referer
    expect(signed_in_user_id).to be_nil
    expect(flash['alert']).to eq('You cannot login since your account has been suspended.')
  end

  it 'does not switch back to a suspended teacher' do
    # Suspend without the learner account check, to show that switching back is refused on its own.
    allow_any_instance_of(User).to receive(:active_for_authentication?).and_wrap_original do |m, *args|
      m.receiver.teacher_preview_student? ? true : m.call(*args)
    end
    teacher.user.suspend!
    post exit_learner_mode_path, headers: referer
    expect(signed_in_user_id).to be_nil
    expect(flash['alert']).to eq('You cannot login since your account has been suspended.')
  end
end
