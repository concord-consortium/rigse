require File.expand_path('../../../spec_helper', __FILE__)

describe Portal::GradesController do

  def mock_grade(stubs={})
    unless stubs.empty?
      stubs.each do |key, value|
        allow(@mock_grade).to receive(key).and_return(value)
      end
    end
    @mock_grade
  end

  before(:each) do
    generate_default_settings_and_jnlps_with_mocks
    generate_portal_resources_with_mocks
    login_admin
  end

  describe "GET index" do
    it "assigns all portal_grades as @portal_grades" do
      allow(Portal::Grade).to receive(:all).and_return([mock_grade])
      get :index
      expect(assigns[:portal_grades]).to eq([mock_grade])
    end
  end

  describe "GET show" do
    it "assigns the requested grade as @portal_grade" do
      allow(Portal::Grade).to receive(:find).with("37").and_return(mock_grade)
      get :show, :id => "37"
      expect(assigns[:portal_grade]).to equal(mock_grade)
    end
  end

  describe "GET new" do
    it "assigns a new grade as @portal_grade" do
      allow(Portal::Grade).to receive(:new).and_return(mock_grade)
      get :new
      expect(assigns[:portal_grade]).to equal(mock_grade)
    end
  end

  describe "GET edit" do
    it "assigns the requested grade as @portal_grade" do
      allow(Portal::Grade).to receive(:find).with("37").and_return(mock_grade)
      get :edit, :id => "37"
      expect(assigns[:portal_grade]).to equal(mock_grade)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created grade as @portal_grade" do
          allow(Portal::Grade).to receive(:new).with({'these' => 'params'}).and_return(mock_grade(:save => true))
        post :create, :portal_grade => {:these => 'params'}
        expect(assigns[:portal_grade]).to equal(mock_grade)
      end

      it "redirects to the created grade" do
          allow(Portal::Grade).to receive(:new).and_return(mock_grade(:save => true))
        post :create, :portal_grade => {}
        expect(response).to redirect_to(portal_grade_url(mock_grade))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved grade as @portal_grade" do
          allow(Portal::Grade).to receive(:new).with({'these' => 'params'}).and_return(mock_grade(:save => false))
        post :create, :portal_grade => {:these => 'params'}
        expect(assigns[:portal_grade]).to equal(mock_grade)
      end

      it "re-renders the 'new' template" do
          allow(Portal::Grade).to receive(:new).and_return(mock_grade(:save => false))
        post :create, :portal_grade => {}
        expect(response).to render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested grade" do
          expect(Portal::Grade).to receive(:find).with("37").and_return(mock_grade)
        expect(mock_grade).to receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :portal_grade => {:these => 'params'}
      end

      it "assigns the requested grade as @portal_grade" do
          allow(Portal::Grade).to receive(:find).and_return(mock_grade(:update_attributes => true))
        put :update, :id => "1"
        expect(assigns[:portal_grade]).to equal(mock_grade)
      end

      it "redirects to the grade" do
          allow(Portal::Grade).to receive(:find).and_return(mock_grade(:update_attributes => true))
        put :update, :id => "1"
        expect(response).to redirect_to(portal_grade_url(mock_grade))
      end
    end

    describe "with invalid params" do
      it "updates the requested grade" do
          expect(Portal::Grade).to receive(:find).with("37").and_return(mock_grade)
        expect(mock_grade).to receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :portal_grade => {:these => 'params'}
      end

      it "assigns the grade as @portal_grade" do
          allow(Portal::Grade).to receive(:find).and_return(mock_grade(:update_attributes => false))
        put :update, :id => "1"
        expect(assigns[:portal_grade]).to equal(mock_grade)
      end

      it "re-renders the 'edit' template" do
          allow(Portal::Grade).to receive(:find).and_return(mock_grade(:update_attributes => false))
        put :update, :id => "1"
        expect(response).to render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested grade" do
      expect(Portal::Grade).to receive(:find).with("37").and_return(mock_grade)
      expect(mock_grade).to receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the portal_grades list" do
      allow(Portal::Grade).to receive(:find).and_return(mock_grade(:destroy => true))
      delete :destroy, :id => "1"
      expect(response).to redirect_to(portal_grades_url)
    end
  end

end
