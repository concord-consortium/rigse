require 'spec_helper'

# API refusals that a stale tab can hit after a switch add the learner mode text in a separate
# learner_mode_hint field, but only for a teacher preview student user or a teacher user with a
# linked teacher preview student. The message stays the same, because API clients may match on it.
# These are background requests, so they get the text that says to reload, not the one that names a
# sidebar link.
RSpec.describe 'Learner mode hint in API refusals', type: :request do
  include Devise::Test::IntegrationHelpers
  # See learner_account_changes_spec.rb.
  before(:all) { Rails.application.reload_routes_unless_loaded }

  let(:to_learner_text) { LearnerModeTextHelper::SWITCHED_TO_LEARNER_BACKGROUND_TEXT }
  let(:to_teacher_text) { LearnerModeTextHelper::SWITCHED_TO_TEACHER_BACKGROUND_TEXT }

  let(:teacher)       { FactoryBot.create(:portal_teacher) }
  let(:clazz)         { teacher.clazzes.first }
  let(:learner_user)  { teacher.find_or_create_teacher_preview_student! }
  let(:other_student) { FactoryBot.create(:full_portal_student) }
  let(:student_clazz) { other_student.student_clazzes.create!(clazz: clazz) }

  def message
    JSON.parse(response.body)['message']
  end

  def hint
    JSON.parse(response.body)['learner_mode_hint']
  end

  describe 'a learner account on teacher endpoints' do
    before(:each) { sign_in learner_user }

    it 'gets the hint from the API Pundit refusal' do
      post remove_from_class_api_v1_students_path, params: { student_clazz_id: student_clazz.id }, as: :json
      expect(response).to have_http_status(:forbidden)
      expect(message).to eq("Not authorized")
      expect(hint).to eq(to_learner_text)
    end

    it 'gets the hint from the teacher classes API' do
      post sort_api_v1_teacher_classes_path, params: { ids: [clazz.id] }, as: :json
      expect(response).to have_http_status(:bad_request)
      expect(message).to eq("You must be logged in as a teacher to use this endpoint")
      expect(hint).to eq(to_learner_text)
    end

    it 'gets the hint when registering a student' do
      post register_api_v1_students_path, params: {
        clazz_id: clazz.id,
        user: { first_name: 'A', last_name: 'B', password: 'password1', password_confirmation: 'password1' }
      }, as: :json
      expect(response).to have_http_status(:bad_request)
      expect(message).to eq("You must be a teacher of the class to register and add students")
      expect(hint).to eq(to_learner_text)
    end

    it 'gets the hint from the bookmarks API' do
      post sort_api_v1_bookmarks_path, params: { clazz_id: clazz.id, ids: [] }, as: :json
      expect(response).to have_http_status(:bad_request)
      expect(message).to eq("You are not authorized to edit bookmarks for this class")
      expect(hint).to eq(to_learner_text)
    end

    describe 'in the assign pop-up' do
      let(:material) { FactoryBot.create(:external_activity) }

      it 'gets a refusal with the hint, not an error, when listing classes' do
        post api_v1_materials_unassigned_clazzes_path,
             params: { material_id: material.id, material_type: 'ExternalActivity' }
        expect(response).to have_http_status(:forbidden)
        expect(message).to eq("You must be logged in as a teacher to assign materials")
        expect(hint).to eq(to_learner_text)
      end

      it 'gets the hint when assigning' do
        post api_v1_materials_assign_to_class_path,
             params: { assign: 1, class_id: clazz.id, material_id: material.id, material_type: 'ExternalActivity' }
        expect(response).to have_http_status(:forbidden)
        expect(message).to eq(
          "You are not allowed to assign/remove ExternalActivity with id of #{material.id} in class #{clazz.id}"
        )
        expect(hint).to eq(to_learner_text)
      end
    end

    describe 'with favorites' do
      let(:material) { FactoryBot.create(:external_activity) }

      it 'gets a refusal with the hint, and no favorite, when adding a favorite' do
        expect {
          post api_v1_materials_add_favorite_path, params: { id: material.id, material_type: 'external_activity' }
        }.not_to change { Favorite.count }
        expect(response).to have_http_status(:forbidden)
        expect(message).to eq("You must be logged in as a teacher to favorite material")
        expect(hint).to eq(to_learner_text)
      end

      it "gets the hint when removing the teacher's favorite" do
        favorite = teacher.user.favorites.create!(favoritable: material)
        post api_v1_materials_remove_favorite_path, params: { favorite_id: favorite.id }
        expect(response).to have_http_status(:bad_request)
        expect(message).to eq("Cannot delete favorite not owned by current user.")
        expect(hint).to eq(to_learner_text)
      end
    end
  end

  describe 'a teacher with favorites' do
    it 'can still add a favorite' do
      sign_in teacher.user
      material = FactoryBot.create(:external_activity)
      post api_v1_materials_add_favorite_path, params: { id: material.id, material_type: 'external_activity' }
      expect(response).to have_http_status(:ok)
      expect(teacher.user.favorites.map(&:favoritable)).to eq([material])
    end
  end

  describe 'a teacher in the assign pop-up' do
    it 'still gets the class list' do
      sign_in teacher.user
      material = FactoryBot.create(:external_activity)
      post api_v1_materials_unassigned_clazzes_path,
           params: { material_id: material.id, material_type: 'ExternalActivity' }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['unassigned_classes'].map { |c| c['id'] }).to eq([clazz.id])
    end
  end

  describe 'joining a class as a teacher' do
    it 'adds the hint for a teacher with a learner account' do
      learner_user
      sign_in teacher.user
      post join_class_api_v1_students_path, params: { class_word: clazz.class_word }, as: :json
      expect(response).to have_http_status(:bad_request)
      expect(message).to eq("You can't signup for a class while logged in as a teacher!")
      expect(hint).to eq(to_teacher_text)
    end

    it 'does not add the hint for a teacher with no learner account' do
      sign_in teacher.user
      post join_class_api_v1_students_path, params: { class_word: clazz.class_word }, as: :json
      expect(message).to eq("You can't signup for a class while logged in as a teacher!")
      expect(hint).to be_nil
    end
  end

  it 'does not add the hint for a normal student' do
    sign_in FactoryBot.create(:full_portal_student).user
    post remove_from_class_api_v1_students_path, params: { student_clazz_id: student_clazz.id }, as: :json
    expect(response).to have_http_status(:forbidden)
    expect(message).to eq('Not authorized')
    expect(hint).to be_nil
  end

  # A token request does not come from a browser tab, so it gets no hint.
  it 'does not add the hint to a token request' do
    token = PortalTokenHelper.unmarked_portal_api_token(learner_user)
    get api_v1_teacher_class_path(clazz.id), headers: { 'Authorization' => "Bearer #{token}" }
    expect(response).to have_http_status(:bad_request)
    expect(message).to eq('You must be logged in as a teacher to use this endpoint')
    expect(hint).to be_nil
  end
end
