require File.expand_path('../../spec_helper', __FILE__)

# The student-only redirects to security questions and consent must skip a teacher preview student
# account. Otherwise the teacher is stopped on the first page in learner mode.
describe ApplicationController, type: :controller do
  controller do
    def index
      render plain: 'ok'
    end
  end

  let(:teacher)      { FactoryBot.create(:portal_teacher) }
  let(:learner_user) { teacher.find_or_create_teacher_preview_student! }
  let(:student_user) { FactoryBot.create(:full_portal_student).user }

  before(:each) do
    generate_default_settings_with_mocks
  end

  context 'when student security questions are required' do
    before(:each) do
      allow(@mock_settings).to receive(:use_student_security_questions).and_return(true)
    end

    it 'does not send a teacher preview student account to its security questions' do
      sign_in learner_user
      get :index
      expect(response).to have_http_status(:ok)
    end

    it 'still sends a normal student to its security questions' do
      sign_in student_user
      get :index
      expect(response).to redirect_to(edit_user_security_questions_path(student_user))
    end
  end

  context 'when user consent is required' do
    before(:each) do
      allow(@mock_settings).to receive(:require_user_consent?).and_return(true)
    end

    it 'does not send a teacher preview student account to the consent page' do
      expect(learner_user.asked_age).to be_falsey
      sign_in learner_user
      get :index
      expect(response).to have_http_status(:ok)
    end

    it 'still sends a normal student to the consent page' do
      expect(student_user.asked_age).to be_falsey
      sign_in student_user
      get :index
      expect(response).to redirect_to(ask_consent_portal_student_path(student_user.portal_student))
    end
  end

  context 'when both are required' do
    before(:each) do
      allow(@mock_settings).to receive(:use_student_security_questions).and_return(true)
      allow(@mock_settings).to receive(:require_user_consent?).and_return(true)
    end

    it 'does not redirect a teacher preview student account' do
      sign_in learner_user
      get :index
      expect(response).to have_http_status(:ok)
    end
  end
end
