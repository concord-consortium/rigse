require File.expand_path('../../../spec_helper', __FILE__)

describe Portal::LearnersController do

  describe "GET report" do
    let(:external_activity) { FactoryBot.create(:external_activity) }

    let(:offering) { FactoryBot.create(
        :portal_offering,
        runnable_id: external_activity.id,
        runnable_type: 'ExternalActivity',
        clazz: clazz
    )}

    let(:clazz)       { FactoryBot.create :portal_clazz, teachers: [teacher] }
    let(:learner)     { FactoryBot.create(:full_portal_learner, { offering_id: offering.id }) }
    let(:post_params) { {id: learner.id }      }
    let(:teacher)     { FactoryBot.create :teacher }
    let(:teacher_b)   { FactoryBot.create :teacher }

    before(:each) do
      sign_in user
      allow(Portal::Learner).to receive(:find).and_return(learner)
    end

    describe "When the teacher of the class requests the report" do
      let(:user)           { teacher.user }
      let(:report_url)     { "https://concord-consortium.github.io/portal-report/" }

      describe "when offering report is used" do
        before(:each) do
          # Ensure that default report is available.
          FactoryBot.create(:default_lara_report, { url: report_url })
        end

        it "should redirect to the external reporting service as configured by the environment" do
          get :report, post_params
          expect(response.location).to match(/#{report_url}/)
        end
        it "should include an authentication token parameter" do
          get :report, post_params
          expect(response.location).to match(/token=([0-9]|[a-f]){32}/)
        end
        it "should include the studentId parameter" do
          get :report, post_params
          match_data = /studentId=(\d+)/.match response.location
          expect(match_data).not_to be_nil
          expect(match_data[1]).to eql(learner.student.user.id.to_s)
        end
      end

      describe "when depreciated report is used" do
        before(:each) do
          FactoryBot.create(:default_lara_report, { url: report_url, report_type: "deprecated-report" })
        end

        it "should include the student_ids parameter" do
          get :report, post_params
          expect(response.location).to match(/student_ids/)
        end
      end
    end

    describe "when the current user is a teacher without access to this offering" do
      let(:user) { teacher_b.user }
      it "should redirect the user to /recent_activity" do
        get :report, post_params
        expect(response).to redirect_to :recent_activity
      end
    end
  end


  # TODO: auto-generated
  describe '#current_clazz' do
    it 'GET current_clazz' do
      get :current_clazz, {}, {}

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#handle_jnlp_session' do
    it 'GET handle_jnlp_session' do
      get :handle_jnlp_session, {}, {}

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#authorize_show' do
    it 'GET authorize_show' do
      get :authorize_show, {}, {}

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#index' do
    it 'GET index' do
      get :index, {}, {}

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#bundle_report' do
    it 'GET bundle_report' do
      get :bundle_report, {}, {}

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#show' do
    it 'GET show' do
      get :show, {}, {}

      expect(response).to have_http_status(:not_found)
    end
  end

  # TODO: auto-generated
  describe '#edit' do
    it 'GET edit' do
      get :edit, {}, {}

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#create' do
    it 'POST create' do
      post :create, {}, {}

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#update' do
    it 'PATCH update' do
      put :update, {}, {}

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#destroy' do
    it 'DELETE destroy' do
      delete :destroy, {}, {}

      expect(response).to have_http_status(:redirect)
    end
  end


end
