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
      @clazz = FactoryBot.create(:portal_clazz, :class_word => @params_for_creation[:clazz][:class_word])
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
    let(:student) { FactoryBot.create(:full_portal_student) }

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

  describe "POST move" do
    before(:each) do

      @student = FactoryBot.create(:full_portal_student)
      @clazz_params = {
        :current_class_word => "currentclassword",
        :new_class_word => "newclassword"
      }
      @clazz_1 = FactoryBot.create(:portal_clazz, :class_word => @clazz_params[:current_class_word])
      @clazz_2 = FactoryBot.create(:portal_clazz, :class_word => @clazz_params[:new_class_word])

      @student.add_clazz(@clazz_1)
      @student.remove_clazz(@clazz_2)

    end


    context "when an external report is correctly configured to support moving a student" do
      before(:each) do
        @external_report = FactoryBot.create(:external_report,
          move_students_api_url: 'http://test.org/api/move_student_work',
          move_students_api_token: 'abc123'
        )
      end

      it 'should flash success notice' do
        stub_request(:post, @external_report.move_students_api_url).
          with(
            headers: {
             'Authorization'=>'Bearer ' + @external_report.move_students_api_token,
             'Content-Type'=>'application/json'
            }).
          to_return(status: 200, body: "Success", headers: {})

        post :move, id: @student.id, clazz: @clazz_params
        expect(flash[:notice]).to match(/Successfully moved student to new class./)
      end
    end

    context "when an external report is incorrectly configured to support moving a student" do

      it 'should return an error if move_students_api_url value is an empty string' do
        external_report = FactoryBot.create(:external_report,
          move_students_api_url: "",
          move_students_api_token: 'abc123'
        )
        expect(HTTParty).not_to receive(:post)
        post :move, id: @student.id, clazz: @clazz_params
      end

      it 'should return an error if move_students_api_url value is a space' do
        external_report = FactoryBot.create(:external_report,
          move_students_api_url: " ",
          move_students_api_token: 'abc123'
        )
        expect(HTTParty).not_to receive(:post)
        post :move, id: @student.id, clazz: @clazz_params
      end

      it 'should return an error if move_students_api_url value is nil' do
        external_report = FactoryBot.create(:external_report,
          move_students_api_url: nil,
          move_students_api_token: 'abc123'
        )
        expect(HTTParty).not_to receive(:post)
        post :move, id: @student.id, clazz: @clazz_params
      end
    end
  end

  describe "POST move_confirm" do
    before(:each) do
      @clazz_params = {
        :current_class_word => "currentclassword",
        :new_class_word => "newclassword"
      }
      student.add_clazz(clazz_1)
      student.remove_clazz(clazz_2)
    end

    let(:teacher)  { FactoryBot.create(:portal_teacher) }
    let(:student) { FactoryBot.create(:full_portal_student) }
    let(:clazz_1) { FactoryBot.create(:portal_clazz, teachers: [teacher], :class_word => @clazz_params[:current_class_word]) }
    let(:clazz_2) { FactoryBot.create(:portal_clazz, teachers: [teacher], :class_word => @clazz_params[:new_class_word]) }

    it 'should ask for confirmation' do
      post :move_confirm, id: student.id, clazz: @clazz_params
      expect(response.body).to have_content("Are you sure you want to move")
    end

    it 'should notify if one or both of the class words are invalid' do
      post :move_confirm, id: student.id, clazz: {:current_class_word => "wrongclassword1", :new_class_word => "wrongclassword2"}
      expect(response.body).to have_content("One or more of the class words you entered is invalid.")
    end

    it 'should notify if the student is already in the class specified to move to' do
      post :move_confirm, id: student.id, clazz: {:current_class_word => @clazz_params[:current_class_word], :new_class_word => @clazz_params[:current_class_word]}
      expect(response.body).to have_content("The student is already in the class you are trying to move them to.")
    end

    it 'should notify if the student is not in the class specified to move from' do
      post :move_confirm, id: student.id, clazz: {:current_class_word => @clazz_params[:new_class_word], :new_class_word => @clazz_params[:new_class_word]}
      expect(response.body).to have_content("The student is not in the class you are trying to move them from.")
    end
  end

  # TODO: auto-generated
  describe '#status' do
    it 'GET status' do
      get :status, id: FactoryBot.create(:portal_student).to_param

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
      get :edit, id: FactoryBot.create(:portal_student).to_param

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#update' do
    xit 'PATCH update' do
      put :update, id: FactoryBot.create(:portal_student).to_param

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#destroy' do
    it 'DELETE destroy' do
      delete :destroy,id: FactoryBot.create(:portal_student).to_param

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#ask_consent' do
    xit 'GET ask_consent' do
      get :ask_consent, id: FactoryBot.create(:portal_student).to_param

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#update_consent' do
    xit 'GET update_consent' do
      get :update_consent, id: FactoryBot.create(:portal_student).to_param

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
