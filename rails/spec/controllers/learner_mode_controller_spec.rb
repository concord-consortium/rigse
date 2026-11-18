require File.expand_path('../../spec_helper', __FILE__)

describe LearnerModeController do
  render_views

  let(:teacher)        { FactoryBot.create(:portal_teacher) }
  let(:teacher_user)   { teacher.user }
  let(:normal_student) { FactoryBot.create(:full_portal_student).user }
  let(:admin)          { FactoryBot.generate(:admin_user) }

  # The teacher's home page depends on a config setting (see current_user_home_path).
  let(:teacher_home_path) { APP_CONFIG[:recent_activity_on_login] ? recent_activity_path : getting_started_path }

  before(:each) do
    generate_default_settings_with_mocks
  end

  def learner_count
    Portal::Student.where(is_teacher_learner: true).count
  end

  describe "GET enter_learner_mode" do
    context "as a teacher with no learner account" do
      before(:each) { sign_in teacher_user }

      it "renders the explanation page and creates nothing" do
        expect {
          get :enter_learner_mode
        }.not_to change(User, :count)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("In learner mode you can join classes with a class word")
        expect(response.body).to include(enter_learner_mode_path(create: true))
        expect(controller.current_user).to eq(teacher_user)
      end

      it "with create=true, creates the learner account and signs it in" do
        expect {
          get :enter_learner_mode, params: { create: "true" }
        }.to change(User, :count).by(1)

        learner_user = teacher.reload.teacher_learner.user
        expect(controller.current_user).to eq(learner_user)
        expect(response).to redirect_to(my_classes_path)
      end

      it "when creation fails, does not switch, leaves no partial account, and asks to try again" do
        allow(Portal::Student).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new(Portal::Student.new))

        expect {
          get :enter_learner_mode, params: { create: "true" }
        }.not_to change(User, :count)

        expect(teacher.reload.teacher_learner_id).to be_nil
        expect(controller.current_user).to eq(teacher_user)
        expect(flash['alert']).to eq("We couldn't start learner mode. Please try again.")
        expect(response).to redirect_to(teacher_home_path)
      end
    end

    context "as a teacher with a learner account" do
      let!(:learner_user) { teacher.find_or_create_teacher_learner! }

      before(:each) { sign_in teacher_user }

      it "signs in the existing learner account and creates nothing" do
        expect { get :enter_learner_mode }.not_to change(User, :count)
        expect(controller.current_user).to eq(learner_user)
        expect(response).to redirect_to(my_classes_path)
      end

      it "with create=true, signs in the existing learner account and creates nothing" do
        expect { get :enter_learner_mode, params: { create: "true" } }.not_to change(User, :count)
        expect(controller.current_user).to eq(learner_user)
      end

      it "ignores user IDs in the request" do
        get :enter_learner_mode, params: { id: admin.id, user: { id: admin.id } }
        expect(controller.current_user).to eq(learner_user)
      end

      it "does not set the admin switch values in the session" do
        get :enter_learner_mode
        expect(session[:original_user_id]).to be_nil
        expect(session[:recently_switched_from_users]).to be_nil
      end
    end

    it "does not let a normal student enter" do
      sign_in normal_student
      expect { get :enter_learner_mode, params: { create: "true" } }.not_to change(User, :count)
      expect(controller.current_user).to eq(normal_student)
      expect(response).to redirect_to(my_classes_path)
      expect(flash['alert']).to include("permission")
    end

    it "sends a learner account home with no error, for example from a stale tab" do
      learner_user = teacher.find_or_create_teacher_learner!
      sign_in learner_user
      expect { get :enter_learner_mode, params: { create: "true" } }.not_to change(User, :count)
      expect(controller.current_user).to eq(learner_user)
      expect(response).to redirect_to(my_classes_path)
      expect(flash['alert']).to be_nil
    end

    it "does not let an anonymous visitor enter" do
      expect { get :enter_learner_mode, params: { create: "true" } }.not_to change(User, :count)
      expect(controller.current_user).to be_nil
      expect(response).to redirect_to(auth_login_path(after_sign_in_path: enter_learner_mode_path))
    end
  end

  describe "GET exit_learner_mode" do
    let!(:learner_user) { teacher.find_or_create_teacher_learner! }

    it "signs in the teacher" do
      sign_in learner_user
      get :exit_learner_mode
      expect(controller.current_user).to eq(teacher_user)
      expect(response).to redirect_to(teacher_home_path)
      expect(session[:original_user_id]).to be_nil
      expect(session[:recently_switched_from_users]).to be_nil
    end

    it "ignores user IDs in the request" do
      sign_in learner_user
      get :exit_learner_mode, params: { id: admin.id, user: { id: admin.id } }
      expect(controller.current_user).to eq(teacher_user)
    end

    it "sends a teacher with a learner account home with no error, for example from a stale tab" do
      sign_in teacher_user
      get :exit_learner_mode
      expect(controller.current_user).to eq(teacher_user)
      expect(response).to redirect_to(teacher_home_path)
      expect(flash['alert']).to be_nil
    end

    it "does not let a teacher with no learner account exit" do
      other_teacher_user = FactoryBot.create(:portal_teacher).user
      sign_in other_teacher_user
      get :exit_learner_mode
      expect(controller.current_user).to eq(other_teacher_user)
      expect(flash['alert']).to include("permission")
    end

    it "does not let a normal student exit" do
      sign_in normal_student
      get :exit_learner_mode
      expect(controller.current_user).to eq(normal_student)
      expect(flash['alert']).to include("permission")
    end

    it "does not let an anonymous visitor exit" do
      get :exit_learner_mode
      expect(controller.current_user).to be_nil
    end
  end

  describe "when an admin switched into the teacher" do
    let!(:learner_user) { teacher.find_or_create_teacher_learner! }

    before(:each) do
      sign_in teacher_user
      session[:original_user_id] = admin.id
      session[:recently_switched_from_users] = [admin.id]
    end

    it "keeps both admin switch values through enter and exit" do
      get :enter_learner_mode
      expect(controller.current_user).to eq(learner_user)
      expect(session[:original_user_id]).to eq(admin.id)
      expect(session[:recently_switched_from_users]).to eq([admin.id])

      get :exit_learner_mode
      expect(controller.current_user).to eq(teacher_user)
      expect(session[:original_user_id]).to eq(admin.id)
      expect(session[:recently_switched_from_users]).to eq([admin.id])
    end
  end
end
