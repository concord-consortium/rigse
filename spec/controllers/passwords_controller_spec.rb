require File.expand_path('../../spec_helper', __FILE__)

describe PasswordsController do
  render_views

  before(:each) do
    generate_default_settings_and_jnlps_with_mocks
  end

  describe "Reset password by login" do
    before(:each) do
      @forgetful_user = Factory.create(:user, :login => "forgetful_jones", :password => "password", :password_confirmation => "password", :email => "valid@test.com")

      @params = { :login => @forgetful_user.login }

      # Stub User.find_by_login because of an rspec-related bug using the dynamic finder
      allow(User).to receive(:find_by_login) do |*login|
        User.first(:conditions => { :login => login })
      end

    end

    it "will fail gracefully if the user is not found by login" do
      @forgetful_user.destroy

      post :create_by_login, @params

      assert_response :success
      expect(flash[:error]).not_to be_nil
    end

    it "will fail gracefully for students without security questions" do
      @forgetful_user.portal_student = Factory.create(:portal_student)

      post :create_by_login, @params

      assert_response :success
      expect(flash[:error]).not_to be_nil
    end

    it "will send an email reset notification for non-students with email" do

      message = double("message")
      expect(message).to receive(:deliver)
      expect(PasswordMailer).to receive(:forgot_password).and_return(message)

      post :create_by_login, @params

      expect(@response).to redirect_to(root_path)
      expect(flash[:error]).to be_nil
    end

    it "will ask security questions for students" do
      @forgetful_user.portal_student = Factory.create(:portal_student)
      Array.new(3) { |i| SecurityQuestion.create({ :question => "test #{i}", :answer => "test" }) }.each { |q| @forgetful_user.security_questions << q }

      expect(PasswordMailer).not_to receive(:forgot_password)

      post :create_by_login, @params

      expect(@response).to redirect_to(password_questions_path(@forgetful_user))
      expect(flash[:error]).to be_nil
    end

    describe "security questions" do
      before(:each) do
        Array.new(3) { |i| SecurityQuestion.create({ :question => "test #{i}", :answer => "test" }) }.each { |q| @forgetful_user.security_questions << q }

        @questions_params = {
          :user_id => @forgetful_user.id
        }

        @answers_params = {
          :user_id => @forgetful_user.id,
          :security_questions => {
            :question0 => { :id => @forgetful_user.security_questions[0].id, :answer => "test" },
            :question1 => { :id => @forgetful_user.security_questions[1].id, :answer => "test" },
            :question2 => { :id => @forgetful_user.security_questions[2].id, :answer => "test" },
          }
        }
      end

      it "will ask the correct security questions" do
        post :questions, @questions_params

        @forgetful_user.security_questions.each do |q|
          expect(@response.body).to include(q.question)
        end
      end

      it "will allow the user to reset their password if they answer their questions correctly" do
        post :check_questions, @answers_params

        password = assigns[:password]
        expect(password).not_to be_nil
        expect(@response).to redirect_to(change_password_path(password.reset_code))
      end

      it "will reject incorrect answers" do
        @answers_params[:security_questions][:question2][:answer] = "wrong"

        post :check_questions, @answers_params

        expect(@response).to redirect_to(password_questions_path(@forgetful_user))
        expect(flash[:error]).not_to be_nil
      end

      it "will raise an error if the user submits an answer to a question that does not belong to the current user" do
        # This is evidence of tampering, so we want to make sure it doesn't get through
        @answers_params[:security_questions][:question2][:id] += 500

        post :check_questions, @answers_params

        assert_response :not_found
      end
    end
  end

  describe "Reset password by email address" do
    before(:each) do
      @forgetful_user = Factory.create(:user, :email => "test@test.com")

      @params = {
        :password => {
          :email => @forgetful_user.email
        }
      }
    end

    it "will send an email reset notification for email addresses" do
      message = double("message")
      expect(message).to receive(:deliver)
      expect(PasswordMailer).to receive(:forgot_password).and_return(message)

      post :create_by_email, @params

      expect(flash[:error]).to be_nil
    end

    it "will produce an error message for an unknown email address" do
      @params[:password][:email] = "bad_____email_____1234567@test.com"
      expect(PasswordMailer).not_to receive(:forgot_password)

      post :create_by_email, @params

      expect(flash[:error]).not_to be_nil
    end
  end
end
