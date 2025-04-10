require File.expand_path('../../../spec_helper', __FILE__)

describe Portal::TeachersController do
  describe "with views" do
    render_views

    before(:each) do
      generate_default_settings_with_mocks
      generate_portal_resources_with_mocks
    end

    before(:each) do
      @school   = FactoryBot.create(:portal_school)
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

        post :create, params: params

        expect(@response).to redirect_to(thanks_for_sign_up_url(type: 'teacher', login: params[:user][:login], host: 'test.host'))

      end
    end
  end

  # TODO: auto-generated
  describe '#show' do
    it 'GET show' do
      get :show, params: { id: FactoryBot.create(:portal_teacher).to_param }

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#destroy' do
    it 'DELETE destroy' do
      delete :destroy, params: { id: FactoryBot.create(:portal_teacher).to_param }

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#new' do
    xit 'GET new' do
      get :new

      expect(response).to have_http_status(:ok)
    end
  end

end
