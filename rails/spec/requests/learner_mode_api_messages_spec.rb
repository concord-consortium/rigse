require 'spec_helper'

# API refusals that a stale tab can hit after a switch add the learner mode text, but only for a
# teacher learner user or a teacher user with a linked teacher learner.
RSpec.describe 'Learner mode text in API refusals', type: :request do
  include Devise::Test::IntegrationHelpers
  # See learner_account_changes_spec.rb.
  before(:all) { Rails.application.reload_routes_unless_loaded }

  let(:to_learner_text) do
    "You may have switched to learner mode in another tab. Use 'Switch back to teacher' in the sidebar to see this page."
  end
  let(:to_teacher_text) do
    "You may have switched back to teacher in another tab. Use 'Switch to learner mode' in the sidebar to see this page."
  end

  let(:teacher)       { FactoryBot.create(:portal_teacher) }
  let(:clazz)         { teacher.clazzes.first }
  let(:learner_user)  { teacher.find_or_create_teacher_learner! }
  let(:other_student) { FactoryBot.create(:full_portal_student) }
  let(:student_clazz) { other_student.student_clazzes.create!(clazz: clazz) }

  def message
    JSON.parse(response.body)['message']
  end

  describe 'a learner account on teacher endpoints' do
    before(:each) { sign_in learner_user }

    it 'gets the text from the API Pundit refusal' do
      post remove_from_class_api_v1_students_path, params: { student_clazz_id: student_clazz.id }, as: :json
      expect(response).to have_http_status(:forbidden)
      expect(message).to eq("Not authorized. #{to_learner_text}")
    end

    it 'gets the text from the teacher classes API' do
      post sort_api_v1_teacher_classes_path, params: { ids: [clazz.id] }, as: :json
      expect(response).to have_http_status(:bad_request)
      expect(message).to eq("You must be logged in as a teacher to use this endpoint. #{to_learner_text}")
    end

    it 'gets the text when registering a student' do
      post register_api_v1_students_path, params: {
        clazz_id: clazz.id,
        user: { first_name: 'A', last_name: 'B', password: 'password1', password_confirmation: 'password1' }
      }, as: :json
      expect(response).to have_http_status(:bad_request)
      expect(message).to eq("You must be a teacher of the class to register and add students. #{to_learner_text}")
    end
  end

  describe 'joining a class as a teacher' do
    it 'adds the text for a teacher with a learner account' do
      learner_user
      sign_in teacher.user
      post join_class_api_v1_students_path, params: { class_word: clazz.class_word }, as: :json
      expect(response).to have_http_status(:bad_request)
      expect(message).to eq("You can't signup for a class while logged in as a teacher! #{to_teacher_text}")
    end

    it 'does not add the text for a teacher with no learner account' do
      sign_in teacher.user
      post join_class_api_v1_students_path, params: { class_word: clazz.class_word }, as: :json
      expect(message).to eq("You can't signup for a class while logged in as a teacher!")
    end
  end

  it 'does not add the text for a normal student' do
    sign_in FactoryBot.create(:full_portal_student).user
    post remove_from_class_api_v1_students_path, params: { student_clazz_id: student_clazz.id }, as: :json
    expect(response).to have_http_status(:forbidden)
    expect(message).to eq('Not authorized')
  end
end
