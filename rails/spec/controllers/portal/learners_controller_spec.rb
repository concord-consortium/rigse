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
          get :report, params: post_params
          expect(response.location).to match(/#{report_url}/)
        end
        it "should include an authentication token parameter" do
          get :report, params: post_params
          expect(response.location).to match(/token=([0-9]|[a-f]){32}/)
        end
        it "should include the studentId parameter" do
          get :report, params: post_params
          match_data = /studentId=(\d+)/.match response.location
          expect(match_data).not_to be_nil
          expect(match_data[1]).to eql(learner.student.user.id.to_s)
        end
      end
    end

    describe "when the current user is a teacher without access to this offering" do
      let(:user) { teacher_b.user }
      it "should redirect the user to /recent_activity" do
        get :report, params: post_params
        expect(response).to redirect_to :recent_activity
      end
    end
  end


  # TODO: auto-generated
  describe '#current_clazz' do
    it 'GET current_clazz' do
      get :current_clazz, params: { id: 1 }

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#authorize_show' do
    it 'GET authorize_show' do
      get :authorize_show, params: { id: 1 }

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#show' do
    it 'GET show' do
      get :show, params: { id: 1 }

      expect(response).to have_http_status(:not_found)
    end
  end

  # TODO: auto-generated
  describe '#edit' do
    it 'GET edit' do
      get :edit, params: { id: 1 }

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#create' do
    it 'POST create' do
      post :create

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#update' do
    it 'PATCH update' do
      put :update, params: { id: 1 }

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#destroy' do
    it 'DELETE destroy' do
      delete :destroy, params: { id: 1 }

      expect(response).to have_http_status(:redirect)
    end
  end


end
