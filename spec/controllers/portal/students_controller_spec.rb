require File.expand_path('../../../spec_helper', __FILE__)

describe Portal::StudentsController do
  render_views

  before(:each) do
    generate_default_settings_and_jnlps_with_mocks
    generate_portal_resources_with_mocks
    allow(Admin::Settings).to receive(:default_settings).and_return(@mock_settings)
    allow(@mock_settings).to receive(:allow_default_class).and_return(true)
  end

  describe "POST create" do
    before(:each) do
      @params_for_creation = {
        :user => {
          :first_name => "Test",
          :last_name => "User",
          :password => "testpassword",
          :password_confirmation => "testpassword"
        },
        :clazz => {
          :class_word => "classword"
        },
        :security_questions => {
          :question0 => {
            :question_idx => 0,
            :answer => "test"
          },
          :question1 => {
            :question_idx => 1,
            :answer => "test"
          },
          :question2 => {
            :question_idx => 2,
            :answer => "test"
          }
        }
      }

      @grade_level = Portal::GradeLevel.create({ :name => "9" }) # default grade level
      @clazz = Factory.create(:portal_clazz, :class_word => @params_for_creation[:clazz][:class_word])
    end

    def stub_user_with_params(user_attributes = nil)
      user_attributes ||= @params_for_creation[:user]
      user_attributes[:login] = Portal::Student.generate_user_login(user_attributes[:first_name], user_attributes[:last_name])
      user_attributes[:email] = Portal::Student.generate_user_email

      @new_user = User.new(user_attributes)
      allow(User).to receive(:new).and_return(@new_user)
      @new_user
    end

    it "creates a user and a student when given valid parameters" do
      stub_user_with_params

      current_user_count = User.count
      current_student_count = Portal::Student.count

      post :create, @params_for_creation

      expect(User.count).to eq(current_user_count + 1)
      expect(Portal::Student.count).to eq(current_student_count + 1)

    end


    # after creating a new account, students still need to login.
    # this is because they need to remember their username and password
    it "clearly shows that the student needs to login after successful create" do
      stub_user_with_params
      post :create, @params_for_creation

      expect(response).to redirect_to(thanks_for_sign_up_url(:type=>"student", :login=>@new_user.login))

    end

    # student is not logged in, so we shouldn't display their classes!
    it "does not show any of the students classes after successful creation" do
      stub_user_with_params
      post :create, @params_for_creation
      expect(response).to redirect_to(thanks_for_sign_up_url(:type=>"student",:login=>@new_user.login))
    end

    it "does not create a user or a student when given incorrect password_confirmation" do
      @params_for_creation[:user][:password_confirmation] = "wrong"

      current_user_count = User.count
      current_student_count = Portal::Student.count

      post :create, @params_for_creation

      expect(User.count).to eq(current_user_count)
      expect(Portal::Student.count).to eq(current_student_count)
    end

    it "does not create a user or a student when given an invalid classword" do
      @params_for_creation[:clazz][:class_word] = "wrong"

      current_user_count = User.count
      current_student_count = Portal::Student.count

      post :create, @params_for_creation

      expect(User.count).to eq(current_user_count)
      expect(Portal::Student.count).to eq(current_student_count)
    end


    describe "security questions" do
      before(:each) do
        allow(@mock_settings).to receive(:use_student_security_questions).and_return(true)
      end

      it "creates security questions when given valid parameters" do
        stub_user_with_params

        expect(SecurityQuestion).to receive(:make_questions_from_hash_and_user)
        expect(SecurityQuestion).to receive(:errors_for_questions_list!)
        expect(@new_user).to receive(:update_security_questions!)

        current_user_count = User.count
        current_student_count = Portal::Student.count

        post :create, @params_for_creation

        expect(User.count).to eq(current_user_count + 1)
        expect(Portal::Student.count).to eq(current_student_count + 1)
      end

      it "does not create a user or a student when given bad security questions" do
        @params_for_creation[:security_questions][:question2][:answer] = "" # empty answers are not acceptable

        current_user_count = User.count
        current_student_count = Portal::Student.count

        post :create, @params_for_creation

        expect(User.count).to eq(current_user_count)
        expect(Portal::Student.count).to eq(current_student_count)
      end

      it "does not check for security questions when they are not enabled in the settings" do
        allow(@mock_settings).to receive(:use_student_security_questions).and_return(false)
        stub_user_with_params

        expect(SecurityQuestion).not_to receive(:errors_for_questions_list!)
        expect(@new_user).not_to receive(:update_security_questions!)

        post :create, @params_for_creation
      end

      it "does not check for security questions when a teacher creates a student" do
        # when a teacher creates a student, the student should have to pick security questions when they log in
        @params_for_creation[:clazz] = {
          :id => @clazz.id
        }

        stub_user_with_params

        expect(SecurityQuestion).not_to receive(:errors_for_questions_list!)
        expect(@new_user).not_to receive(:update_security_questions!)

        post :create, @params_for_creation
      end

      it "checks for security questions when a student signs themselves up" do
        stub_user_with_params

        expect(SecurityQuestion).to receive(:errors_for_questions_list!)
        expect(@new_user).to receive(:update_security_questions!)

        post :create, @params_for_creation
      end
    end
  end

  describe "GET show" do
    let(:student) { Factory(:full_portal_student) }

    it "should redirect when current user isn't an admin" do
      get :show, id: student.id
      expect(response).to redirect_to_path auth_login_path
    end

    it "should not redirect when current user is an admin" do
      login_admin
      get :show, id: student.id
      expect(response).not_to redirect_to(:home)
      expect(response).to be_success
      expect(response.status).to eq(200)
    end
  end

  # TODO: auto-generated
  describe '#status' do
    it 'GET status' do
      get :status, id: Factory.create(:portal_student).to_param

      expect(response).to have_http_status(406)
    end
  end

  # TODO: auto-generated
  describe '#index' do
    it 'GET index' do
      get :index

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#edit' do
    xit 'GET edit' do
      get :edit, id: Factory.create(:portal_student).to_param

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#update' do
    xit 'PATCH update' do
      put :update, id: Factory.create(:portal_student).to_param

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#destroy' do
    it 'DELETE destroy' do
      delete :destroy,id: Factory.create(:portal_student).to_param

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#ask_consent' do
    xit 'GET ask_consent' do
      get :ask_consent, id: Factory.create(:portal_student).to_param

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#update_consent' do
    xit 'GET update_consent' do
      get :update_consent, id: Factory.create(:portal_student).to_param

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#signup' do
    it 'GET signup' do
      get :signup, {}, {}

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#register' do
    it 'GET register' do
      get :register, {}, {}

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#confirm' do
    xit 'GET confirm' do
      get :confirm, class: { class_word: 'word' }

      expect(response).to have_http_status(:ok)
    end
  end


end
