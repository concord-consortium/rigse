require File.expand_path('../../../spec_helper', __FILE__)

describe Portal::StudentsController do
  render_views

  before(:each) do
    generate_default_project_and_jnlps_with_mocks
    generate_portal_resources_with_mocks
    Admin::Project.stub!(:default_project).and_return(@mock_project)
    @mock_project.stub!(:allow_default_class).and_return(true)
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
      User.stub!(:new).and_return(@new_user)
    end

    it "creates a user and a student when given valid parameters" do
      stub_user_with_params

      current_user_count = User.count(:all)
      current_student_count = Portal::Student.count(:all)

      post :create, @params_for_creation

      User.count(:all).should == current_user_count + 1
      Portal::Student.count(:all).should == current_student_count + 1

    end


    # after creating a new account, students still need to login.
    # this is because they need to remember their username and password
    it "clearly shows that the student needs to login after successful create" do
      stub_user_with_params
      post :create, @params_for_creation

      # should show text "your username is"
      assert_select "p", /username\s+is/i

      # should show directions to login:
      assert_select "p", /login/i
    end

    # student is not logged in, so we shouldn't display their classes!
    it "does not show any of the students classes after successful creation" do
      stub_user_with_params
      post :create, @params_for_creation
      assert_select "*#clazzes_nav", false
      assert_select "input#login"
    end

    it "does not create a user or a student when given incorrect password_confirmation" do
      @params_for_creation[:user][:password_confirmation] = "wrong"

      current_user_count = User.count(:all)
      current_student_count = Portal::Student.count(:all)

      post :create, @params_for_creation

      User.count(:all).should == current_user_count
      Portal::Student.count(:all).should == current_student_count
    end

    it "does not create a user or a student when given an invalid classword" do
      @params_for_creation[:clazz][:class_word] = "wrong"

      current_user_count = User.count(:all)
      current_student_count = Portal::Student.count(:all)

      post :create, @params_for_creation

      User.count(:all).should == current_user_count
      Portal::Student.count(:all).should == current_student_count
    end


    describe "security questions" do
      before(:each) do
        @mock_project.stub!(:use_student_security_questions).and_return(true)
      end

      it "creates security questions when given valid parameters" do
        stub_user_with_params

        SecurityQuestion.should_receive(:make_questions_from_hash_and_user)
        SecurityQuestion.should_receive(:errors_for_questions_list!)
        @new_user.should_receive(:update_security_questions!)

        current_user_count = User.count(:all)
        current_student_count = Portal::Student.count(:all)

        post :create, @params_for_creation

        User.count(:all).should == current_user_count + 1
        Portal::Student.count(:all).should == current_student_count + 1
      end

      it "does not create a user or a student when given bad security questions" do
        @params_for_creation[:security_questions][:question2][:answer] = "" # empty answers are not acceptable

        current_user_count = User.count(:all)
        current_student_count = Portal::Student.count(:all)

        post :create, @params_for_creation

        User.count(:all).should == current_user_count
        Portal::Student.count(:all).should == current_student_count
      end

      it "does not check for security questions when they are not enabled in the project" do
        @mock_project.stub!(:use_student_security_questions).and_return(false)
        stub_user_with_params

        SecurityQuestion.should_not_receive(:errors_for_questions_list!)
        @new_user.should_not_receive(:update_security_questions!)

        post :create, @params_for_creation
      end

      it "does not check for security questions when a teacher creates a student" do
        # when a teacher creates a student, the student should have to pick security questions when they log in
        @params_for_creation[:clazz] = {
          :id => @clazz.id
        }

        stub_user_with_params

        SecurityQuestion.should_not_receive(:errors_for_questions_list!)
        @new_user.should_not_receive(:update_security_questions!)

        post :create, @params_for_creation
      end

      it "checks for security questions when a student signs themselves up" do
        stub_user_with_params

        SecurityQuestion.should_receive(:errors_for_questions_list!)
        @new_user.should_receive(:update_security_questions!)

        post :create, @params_for_creation
      end
    end
  end
end
