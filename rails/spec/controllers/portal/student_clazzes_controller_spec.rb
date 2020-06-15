require File.expand_path('../../../spec_helper', __FILE__)

describe Portal::StudentClazzesController do
  render_views
    
  def mock_clazz(stubs={})
    mock_clazz = FactoryBot.create(:portal_clazz, stubs) #mock_model(Portal::Clazz)
    #mock_clazz.stub!(stubs) unless stubs.empty?

    mock_clazz
  end
  
  describe "Delete remove a student" do
    before(:each) do
      @mock_school = FactoryBot.create(:portal_school)
      @authorized_teacher = FactoryBot.create(:portal_teacher, :user => FactoryBot.create(:confirmed_user, :login => "authorized_teacher"), :schools => [@mock_school])
      @authorized_student = FactoryBot.create(:portal_student, :user =>FactoryBot.create(:confirmed_user, :login => "authorized_student"))
      
      @mock_clazz_name = "Random Test Class"
      @mock_course = FactoryBot.create(:portal_course, :name => @mock_clazz_name, :school => @mock_school)
      @mock_clazz = mock_clazz({ :name => @mock_clazz_name, :teachers => [@authorized_teacher], :course => @mock_course })
      
      @authorized_student.add_clazz(@mock_clazz)
      @mock_clazz.reload
      @mock_student_clazz = Portal::StudentClazz.find_by_clazz_id_and_student_id(@mock_clazz.id, @authorized_student.id)
    end

    it "Remove a student from a class" do
      post_params = {
        :id => @mock_student_clazz.id.to_s
      }
      delete :destroy, post_params
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
  describe '#new' do
    it 'GET new' do
      get :new, {}, {}

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#show' do
    it 'GET show' do
      get :show, {}, {}

      expect(response).to have_http_status(:not_found)
    end
  end

  # TODO: auto-generated
  describe '#edit' do
    it 'GET edit' do
      get :edit, {}, {}

      expect(response).to have_http_status(:not_found)
    end
  end

  # TODO: auto-generated
  describe '#create' do
    it 'POST create' do
      post :create, {}, {}

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#update' do
    it 'PATCH update' do
      put :update, {}, {}

      expect(response).to have_http_status(:not_found)
    end
  end

end
