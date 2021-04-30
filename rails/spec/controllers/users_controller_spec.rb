require File.expand_path('../../spec_helper', __FILE__)
describe UsersController do
  fixtures :users
  fixtures :roles

  render_views

  context "when logged in" do
    before(:each) do
      generate_default_settings_and_jnlps_with_mocks
    end

    describe "as admin" do
      # There are 3 users already loaded from fixtures in:
      # rails/spec/fixtures/users.yml
      # ID: email, state:
      # 1: quentin@example.com, active
      # 2: aaron@example.com, pending
      # 3: salty_dog@example.com, active
      let(:quentin) { User.find(1) }
      let(:arron)   { User.find(2) }
      let(:salty)   { User.find(3) }
      let(:all_our_users) { [arron, salty, quentin] }
      it "lets user view users index page" do
        login_admin
        get :index
        expect(response.status).to eq(200)
      end

      it "lets admin user search for users on the index page" do
        post_params = { :search => 'quentin' }
        login_admin
        post :index, post_params
        expect(response.status).to eq(200)
        expect(assigns(:users)).to include(quentin)
      end

      it "lets user search for project researchers" do
        post_params = {
          :search => '',
          :project_researcher => true
        }
        login_admin
        post :index, post_params
        expect(response.status).to eq(200)
      end

      it "lets user search for project admins" do
        post_params = {
          :search => '',
          :project_admin => true
        }
        login_admin
        post :index, post_params
        expect(response.status).to eq(200)
      end

      describe "admin searching for portal admins" do
        let(:search_string) { '' }
        let(:admin_only) { true }
        let(:post_params) { {search: search_string, portal_admin: admin_only} }
        before(:each) do
          login_admin
          post :index, post_params
        end

        describe "with no search string" do
          it "returns a list with quentin(admin), not salty (not admin)" do
            expect(response.status).to eq(200)
            expect(assigns(:users)).not_to include(salty)
            expect(assigns(:users)).to include(quentin)
          end
        end

        describe "searching for salty (non-admin)" do
          let(:search_string) { "salty" }
          it "doesn't display salty or quentin" do
            expect(response.status).to eq(200)
            expect(assigns(:users)).not_to include(salty)
            expect(assigns(:users)).not_to include(quentin)
          end
        end

        describe "searching for quentin (admin)" do
          let(:search_string) { "quentin" }
          it "displays quentin" do
            expect(response.status).to eq(200)
            expect(assigns(:users)).not_to include(salty)
            expect(assigns(:users)).to include(quentin)
          end
        end
      end
    end

    describe "as manager" do
      it "lets user view users index page" do
        login_manager
        get :index
        expect(response.status).to eq(200)
      end
    end

    describe "as researcher" do
      it "does not let user view users index page" do
        login_researcher
        get :index
        expect(response.status).to eq(302)
      end
    end

  end

  context "when logged out" do
    before(:each) do
      generate_default_settings_and_jnlps_with_mocks
      logout_user
    end

    it 'allows signup' do
      skip "Broken example"
      expect do
        create_user
        expect(response).to be_redirect
      end.to change(User, :count).by(1)
    end

    it 'signs up user in pending state' do
      skip "Broken example"
      create_user
      assigns(:user).reload
      expect(assigns(:user)).to be_pending
    end

    it 'signs up user with activation code' do
      skip "Broken example"
      create_user
      assigns(:user).reload
      expect(assigns(:user).activation_code).not_to be_nil
    end
    it 'requires login on signup' do
      skip "Broken example"
      expect do
        create_user(:login => nil)
        expect(assigns[:user].errors[:login]).not_to be_nil
        expect(response).to be_success
      end.not_to change(User, :count)
    end

    it 'requires password on signup' do
      skip "Broken example"
      expect do
        create_user(:password => nil)
        expect(assigns[:user].errors[:password]).not_to be_nil
        expect(response).to be_success
      end.not_to change(User, :count)
    end

    it 'requires password confirmation on signup' do
      skip "Broken example"
      expect do
        create_user(:password_confirmation => nil)
        expect(assigns[:user].errors[:password_confirmation]).not_to be_nil
        expect(response).to be_success
      end.not_to change(User, :count)
    end

    it 'requires email on signup' do
      skip "Broken example"
      expect do
        create_user(:email => nil)
        expect(assigns[:user].errors[:email]).not_to be_nil
        expect(response).to be_success
      end.not_to change(User, :count)
    end

    it 'activates user' do
      skip "Broken example"
      expect(User.authenticate('aaron', 'monkey')).to be_nil
      get :activate, :activation_code => users(:aaron).activation_code
      expect(response).to redirect_to('/login')
      expect(flash['notice']).not_to be_nil
      expect(flash['error']).to     be_nil
      expect(User.authenticate('aaron', 'monkey')).to eq(users(:aaron))
    end

    it 'does not activate user without key' do
      skip "Broken example"
      get :activate
      expect(flash['notice']).to     be_nil
      expect(flash['error']).not_to be_nil
    end

    it 'does not activate user with blank key' do
      skip "Broken example"
      get :activate, :activation_code => ''
      expect(flash['notice']).to     be_nil
      expect(flash['error']).not_to be_nil
    end

    it 'does not activate user with bogus key' do
      skip "Broken example"
      get :activate, :activation_code => 'i_haxxor_joo'
      expect(flash['notice']).to     be_nil
      expect(flash['error']).not_to be_nil
    end

    it 'shows thank you page to teacher on successful registration' do

      get :registration_successful, {:type => 'teacher', :login => "test"}

      expect(@response).to render_template("users/thanks")

      assert_select 'h2', /thanks/i
      assert_select 'p', /activation code/i

    end

    it 'shows thank you page to the student with login name on successful registration' do

      get :registration_successful, {:type => 'student', :login => "test"}

      expect(@response).to render_template("portal/students/signup_success")

      # should show text "your username is"
      assert_select "p", /username\s+is/i

      # should show directions to login:
      assert_select 'p', /login/i

      assert_select "*#clazzes_nav", false

      expect(flash['error']).to be_nil
      expect(flash['notice']).to be_nil
    end
  end

  def create_user(options = {})
    post :create, :user => { :login => 'quire', :email => 'quire@example.com',
      :password => 'quire69', :password_confirmation => 'quire69' }.merge(options)
  end
end
