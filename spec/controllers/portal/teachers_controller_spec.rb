require File.expand_path('../../../spec_helper', __FILE__)

describe Portal::TeachersController do
  describe "POST create" do
    it "should complain if the login is the same except for case" do
      school   = Factory.create(:portal_school)
      selector = double(:portal_selector, :school => school, :valid? => true)
      allow(Portal::SchoolSelector).to receive(:new).and_return(selector) 
      Factory.create(:user, :login => "tteacher")

      params = {
        :user => {
          :first_name => "Test",
          :last_name => "Teacher",
          :email => "test@fake.edu",
          :login => "TTeacher",
          :password => "password",
          :password_confirmation => "password"
        }
      }
        
      post :create, params

      expect(assigns(:user)).not_to be_valid
    end
  end

  describe "with views" do
    render_views
    
    before(:each) do
      generate_default_settings_and_jnlps_with_mocks
      generate_portal_resources_with_mocks
    end

    before(:each) do
      @school   = Factory.create(:portal_school)
      @selector = Portal::SchoolSelector.new({
        :country => Portal::SchoolSelector::USA,
        :state   => 'MA'})
      allow(@selector).to receive(:valid?).and_return true
      @selector.school = @school
      @selector.district = @school.district
      allow(Portal::SchoolSelector).to receive(:new).and_return(@selector) 
    end

    describe "POST create" do
      it "should create a user and a teacher if all fields are valid" do
        params = {
          :user => {
            :first_name => "Test",
            :last_name => "Teacher",
            :email => "test@fake.edu",
            :login => "tteacher",
            :password => "password",
            :password_confirmation => "password"
          }
        }
        
        current_user_count = User.count(:all)
        current_teacher_count = Portal::Teacher.count(:all)
        
        post :create, params
        
        expect(@response).to redirect_to(thanks_for_sign_up_url(:type=>'teacher',:login=>params[:user][:login]))
        
      end
      
      it "should not force the teacher not to select a school" do
        params = {
          :user => {
            :first_name => "Test",
            :last_name => "Teacher",
            :email => "test@fake.edu",
            :login => "tteacher",
            :password => "password",
            :password_confirmation => "password"
          }
        }
        allow(@selector).to receive(:valid?).and_return false
        current_user_count = User.count(:all)
        current_teacher_count = Portal::Teacher.count(:all)
        
        post :create, params
        
        expect(User.count(:all)).to eq(current_user_count), "TeachersController#create erroneously created a User when given invalid POST data"
        expect(Portal::Teacher.count(:all)).to eq(current_teacher_count), "TeachersController#create erroneously created a Portal::Teacher when given invalid POST data"

        #expect(flash.now[:error]).not_to be_nil
        expect(flash[:notice]).to be_nil
        expect(@response.body).to include("must select a school")
        expect(@response.body).to include("Sorry")
      end
    end
  end  

  # TODO: auto-generated
  describe '#teacher_admin_or_manager' do
    it 'GET teacher_admin_or_manager' do
      get :teacher_admin_or_manager, {}, {}

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
  describe '#show' do
    it 'GET show' do
      get :show, id: Factory.create(:portal_teacher).to_param

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#edit' do
    it 'GET edit' do
      get :edit, id: Factory.create(:portal_teacher).to_param

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#update' do
    it 'PATCH update' do
      put :update, id: Factory.create(:portal_teacher).to_param

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#destroy' do
    it 'DELETE destroy' do
      delete :destroy, id: Factory.create(:portal_teacher).to_param

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#successful_creation' do
    it 'GET successful_creation' do
      get :successful_creation, {}, {}

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#failed_creation' do
    it 'GET failed_creation' do
      get :failed_creation, {}, {}

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#new' do
    xit 'GET new' do
      get :new, {}, {}

      expect(response).to have_http_status(:ok)
    end
  end

end
