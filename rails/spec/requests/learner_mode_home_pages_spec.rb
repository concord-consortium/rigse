require 'spec_helper'

# A tab left open on a home page is reloaded after a switch in another tab. The page is
# refused, and the user goes to the right home page with the learner mode text.
RSpec.describe 'Home pages after a learner mode switch', type: :request do
  include Devise::Test::IntegrationHelpers
  # See learner_account_changes_spec.rb.
  before(:all) { Rails.application.reload_routes_unless_loaded }
  before(:each) { generate_default_settings_with_mocks }

  let(:to_learner_text) { LearnerModeTextHelper::SWITCHED_TO_LEARNER_TEXT }
  let(:to_teacher_text) { LearnerModeTextHelper::SWITCHED_TO_TEACHER_TEXT }

  let(:teacher)      { FactoryBot.create(:portal_teacher) }
  let(:learner_user) { teacher.find_or_create_teacher_learner! }

  # The teacher's home page depends on a config setting (see current_user_home_path).
  let(:teacher_home_path) { APP_CONFIG[:recent_activity_on_login] ? recent_activity_path : getting_started_path }

  describe 'My Classes' do
    it 'sends a teacher with a learner account home with the learner mode text' do
      learner_user
      sign_in teacher.user
      get my_classes_path
      expect(response).to redirect_to(teacher_home_path)
      expect(flash['alert']).to eq("You don't have permission to view this page. #{to_teacher_text}")
    end

    it 'sends a teacher with no learner account home without the learner mode text' do
      sign_in teacher.user
      get my_classes_path
      expect(response).to redirect_to(teacher_home_path)
      expect(flash['alert']).to eq("You don't have permission to view this page")
    end

    it 'sends an anonymous visitor to the login page' do
      get my_classes_path
      expect(response).to redirect_to(auth_login_path(after_sign_in_path: my_classes_path))
    end

    it 'still shows the page to a learner account' do
      sign_in learner_user
      get my_classes_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'Getting Started' do
    it 'sends a learner account home with the learner mode text' do
      sign_in learner_user
      get getting_started_path
      expect(response).to redirect_to(my_classes_path)
      expect(flash['alert']).to eq("You don't have permission to view this page. #{to_learner_text}")
    end

    it 'still shows the page to a teacher' do
      sign_in teacher.user
      get getting_started_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'Recent Activity' do
    it 'uses "view" in the message for a learner account' do
      sign_in learner_user
      get recent_activity_path
      expect(response).to redirect_to(my_classes_path)
      expect(flash['alert']).to eq("You don't have permission to view this page. #{to_learner_text}")
    end
  end
end
