require 'spec_helper'

# A tab left open on a teacher page submits its form after the teacher entered learner mode in
# another tab. The switch keeps the form's security token valid, so the request runs as the
# learner account, is refused, and shows the learner mode text.
RSpec.describe 'A stale tab after switching to learner mode', type: :request do
  include Devise::Test::IntegrationHelpers
  # See learner_account_changes_spec.rb.
  before(:all) { Rails.application.reload_routes_unless_loaded }

  around(:each) do |example|
    old_value = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
    example.run
  ensure
    ActionController::Base.allow_forgery_protection = old_value
  end

  let(:teacher) { FactoryBot.create(:portal_teacher) }

  it 'refuses a stale form with the learner mode text and changes nothing' do
    sign_in teacher.user
    get preferences_user_path(teacher.user)
    token = response.body[/name="authenticity_token" value="([^"]+)"/, 1]
    expect(token).to be_present

    post enter_learner_mode_path, params: { authenticity_token: token }

    put user_path(teacher.user), params: { authenticity_token: token, user: { first_name: 'Changed' } }
    expect(response).to redirect_to(my_classes_path)
    expect(flash['alert']).to end_with(LearnerModeTextHelper::SWITCHED_TO_LEARNER_TEXT)
    expect(teacher.user.reload.first_name).not_to eq('Changed')
  end
end
