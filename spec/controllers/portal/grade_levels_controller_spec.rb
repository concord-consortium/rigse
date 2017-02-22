require File.expand_path('../../../spec_helper', __FILE__)

describe Portal::GradeLevelsController do

  def mock_grade_level(stubs={})
    unless stubs.empty?
      stubs.each do |key, value|
        allow(@mock_grade_level).to receive(key).and_return(value)
      end
    end
    @mock_grade_level
  end

  before(:each) do
    generate_default_settings_and_jnlps_with_mocks
    generate_portal_resources_with_mocks
    login_admin
  end

  describe "GET index" do
    it "assigns all portal_grade_levels as @portal_grade_levels" do
      allow(Portal::GradeLevel).to receive(:all).and_return([mock_grade_level])
      get :index
      expect(assigns[:portal_grade_levels]).to eq([mock_grade_level])
    end
  end

  describe "GET show" do
    it "assigns the requested grade_level as @portal_grade_level" do
      allow(Portal::GradeLevel).to receive(:find).with("37").and_return(mock_grade_level)
      get :show, :id => "37"
      expect(assigns[:portal_grade_level]).to equal(mock_grade_level)
    end
  end
  
  describe "GET new" do
    it "assigns a new grade_level as @portal_grade_level" do
      allow(Portal::GradeLevel).to receive(:new).and_return(mock_grade_level)
      get :new
      expect(assigns[:portal_grade_level]).to equal(mock_grade_level)
    end
  end
  
  describe "GET edit" do
    it "assigns the requested grade_level as @portal_grade_level" do
      allow(Portal::GradeLevel).to receive(:find).with("37").and_return(mock_grade_level)
      get :edit, :id => "37"
      expect(assigns[:portal_grade_level]).to equal(mock_grade_level)
    end
  end
  
  describe "POST create" do
  
    describe "with valid params" do
      it "assigns a newly created grade_level as @portal_grade_level" do
        allow(Portal::GradeLevel).to receive(:new).with({'these' => 'params'}).and_return(mock_grade_level(:save => true))
        post :create, :portal_grade_level => {:these => 'params'}
        expect(assigns[:portal_grade_level]).to equal(mock_grade_level)
      end
  
      it "redirects to the created grade_level" do
        allow(Portal::GradeLevel).to receive(:new).and_return(mock_grade_level(:save => true))
        post :create, :portal_grade_level => {}
        expect(response).to redirect_to(portal_grade_level_url(mock_grade_level))
      end
    end
  
    describe "with invalid params" do
      it "assigns a newly created but unsaved grade_level as @portal_grade_level" do
        allow(Portal::GradeLevel).to receive(:new).with({'these' => 'params'}).and_return(mock_grade_level(:save => false))
        post :create, :portal_grade_level => {:these => 'params'}
        expect(assigns[:portal_grade_level]).to equal(mock_grade_level)
      end
  
      it "re-renders the 'new' template" do
        allow(Portal::GradeLevel).to receive(:new).and_return(mock_grade_level(:save => false))
        post :create, :portal_grade_level => {}
        expect(response).to render_template('new')
      end
    end
  
  end
  
  describe "PUT update" do
  
    describe "with valid params" do
      it "updates the requested grade_level" do
        expect(Portal::GradeLevel).to receive(:find).with("37").and_return(mock_grade_level)
        expect(mock_grade_level).to receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :portal_grade_level => {:these => 'params'}
      end
  
      it "assigns the requested grade_level as @portal_grade_level" do
        allow(Portal::GradeLevel).to receive(:find).and_return(mock_grade_level(:update_attributes => true))
        put :update, :id => "1"
        expect(assigns[:portal_grade_level]).to equal(mock_grade_level)
      end
  
      it "redirects to the grade_level" do
        allow(Portal::GradeLevel).to receive(:find).and_return(mock_grade_level(:update_attributes => true))
        put :update, :id => "1"
        expect(response).to redirect_to(portal_grade_level_url(mock_grade_level))
      end
    end
  
    describe "with invalid params" do
      it "updates the requested grade_level" do
        expect(Portal::GradeLevel).to receive(:find).with("37").and_return(mock_grade_level)
        expect(mock_grade_level).to receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :portal_grade_level => {:these => 'params'}
      end
  
      it "assigns the grade_level as @portal_grade_level" do
        allow(Portal::GradeLevel).to receive(:find).and_return(mock_grade_level(:update_attributes => false))
        put :update, :id => "1"
        expect(assigns[:portal_grade_level]).to equal(mock_grade_level)
      end
  
      it "re-renders the 'edit' template" do
        allow(Portal::GradeLevel).to receive(:find).and_return(mock_grade_level(:update_attributes => false))
        put :update, :id => "1"
        expect(response).to render_template('edit')
      end
    end
  
  end
  
  describe "DELETE destroy" do
    it "destroys the requested grade_level" do
      expect(Portal::GradeLevel).to receive(:find).with("37").and_return(mock_grade_level)
      expect(mock_grade_level).to receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "redirects to the portal_grade_levels list" do
      allow(Portal::GradeLevel).to receive(:find).and_return(mock_grade_level(:destroy => true))
      delete :destroy, :id => "1"
      expect(response).to redirect_to(portal_grade_levels_url)
    end
  end

end
