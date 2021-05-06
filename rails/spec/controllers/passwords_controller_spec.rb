require File.expand_path('../../spec_helper', __FILE__)

describe PasswordsController do
  render_views

  before(:each) do
    generate_default_settings_and_jnlps_with_mocks
  end

  describe "Reset password" do
    before(:each) do
      @forgetful_user = FactoryBot.create(:user, :login => "forgetful_jones", :password => "password", :password_confirmation => "password", :email => "valid@test.com")

      @params = { :login => @forgetful_user.login }

      # Stub User.find_by_login because of an rspec-related bug using the dynamic finder
      allow(User).to receive(:find_by_login) do |*login|
        User.where(login: login).first
      end

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
        post :questions, params: @questions_params

        @forgetful_user.security_questions.each do |q|
          expect(@response.body).to include(q.question)
        end
      end

      it "will allow the user to reset their password if they answer their questions correctly" do
        post :check_questions, params: @answers_params

        password = assigns[:password]
        expect(password).not_to be_nil
        expect(@response).to redirect_to(change_password_path(password.reset_code))
      end

      it "will reject incorrect answers" do
        @answers_params[:security_questions][:question2][:answer] = "wrong"

        post :check_questions, params: @answers_params

        expect(@response).to redirect_to(password_questions_path(@forgetful_user))
        expect(flash['error']).not_to be_nil
      end

      it "will raise an error if the user submits an answer to a question that does not belong to the current user" do
        # This is evidence of tampering, so we want to make sure it doesn't get through
        @answers_params[:security_questions][:question2][:id] += 500

        post :check_questions, params: @answers_params
        expect(response.status).to eq(404)
      end
    end
  end

  # TODO: auto-generated
  describe '#login' do
    it 'GET login' do
      get :login

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#questions' do
    it 'GET questions' do
      get :questions, params: { user_id: 0 }

      expect(response).to have_http_status(:not_found)
    end
  end

  # TODO: auto-generated
  describe '#reset' do
    it 'GET reset' do
      get :reset, params: { reset_code: 'test' }

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#update_users_password' do
    xit 'GET update_users_password' do
      get :update_users_password, params: { user_reset_password: { password: 'password' } }

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#update' do
    it 'PATCH update' do
      put :update, params: { id: 1 }

      expect(response).to have_http_status(:not_found)
    end
  end


end
