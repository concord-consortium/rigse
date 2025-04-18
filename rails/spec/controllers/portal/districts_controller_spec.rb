require File.expand_path('../../../spec_helper', __FILE__)

describe Portal::DistrictsController do

  let(:portal_district_params) {{
    "description" => "Test District", "leaid" => "1", "name" => "Test District",
    "nces_district_id" => "2", "state" => "MA", "zipcode" => "01234"
  }}

  def mock_district(_stubs={})
    stubs = {
      :name => 'default district',
      :description => 'default district',
      :changeable? => :false,
      :schools => [],
      :nces_district_id => nil
    }
    stubs.merge!(_stubs)
    @mock_district = mock_model(Portal::District, stubs)
    @mock_district
  end

  before(:each) do
    generate_default_settings_with_mocks
    generate_portal_resources_with_mocks
    login_admin
    @district = mock_district
  end

  describe "GET index" do
    it "assigns all portal_districts as @portal_districts" do
      allow(Portal::District).to receive(:search).and_return([@district])
      get :index
      expect(assigns[:portal_districts]).to include @district
    end
  end

  describe "GET show" do
    it "assigns the requested district as @portal_district" do
      allow(Portal::District).to receive(:find).with("37").and_return(@district)
      get :show, params: { :id => "37" }
      expect(assigns[:portal_district]).to equal(@district)
    end
  end

  describe "GET new" do
    it "assigns a new district as @portal_district" do
      allow(Portal::District).to receive(:new).and_return(@district)
      get :new
      expect(assigns[:portal_district]).to equal(@district)
    end
  end

  describe "GET edit" do
    it "assigns the requested district as @portal_district" do
      allow(Portal::District).to receive(:find).with("37").and_return(@district)
      get :edit, params: { :id => "37" }
      expect(assigns[:portal_district]).to equal(@district)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created district as @portal_district" do
        allow(@district).to receive_messages(:save => true)
        allow(Portal::District).to receive(:new).with(permit_params!(portal_district_params)).and_return(@district)
        post :create, params: { :portal_district => portal_district_params }
        expect(assigns[:portal_district]).to equal(@district)
      end

      it "redirects to the created district" do
        allow(@district).to receive_messages(:id => 37, :save => true )
        allow(Portal::District).to receive(:new).and_return(@district)
        post :create, params: { :portal_district => {} }
        expect(response).to redirect_to(portal_district_url(@district, host: 'test.host'))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved district as @portal_district" do
        allow(@district).to receive_messages(:save => false)
        allow(Portal::District).to receive(:new).with(permit_params!(portal_district_params)).and_return(@district)
        post :create, params: { :portal_district => portal_district_params }
        expect(assigns[:portal_district]).to equal(@district)
      end

      it "re-renders the 'new' template" do
        allow(@district).to receive_messages(:save => false)
        allow(Portal::District).to receive(:new).and_return(@district)
        post :create, params: { :portal_district => {} }
        expect(response).to render_template('new')
      end
   end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested district" do
        expect(Portal::District).to receive(:find).with("37").and_return(@district)
        expect(@mock_district).to receive(:update).with(permit_params!(portal_district_params)).and_return(true)
        put :update, params: { :id => "37", :portal_district => portal_district_params }
      end

      it "assigns the requested district as @portal_district" do
        allow(@district).to receive_messages(:update => true)
        allow(Portal::District).to receive(:find).and_return(@district)
        put :update, params: { :id => "1" }
        expect(assigns[:portal_district]).to equal(@district)
      end

      it "redirects to the district" do
        allow(@district).to receive_messages(:update => true)
        allow(Portal::District).to receive(:find).and_return(@district)
        put :update, params: { :id => "1" }
        expect(response).to redirect_to(portal_district_url(@district, host: 'test.host'))
      end
    end

    describe "with invalid params" do
      it "updates the requested district" do
        expect(Portal::District).to receive(:find).with("37").and_return(@district)
        expect(@district).to receive(:update).with(permit_params!(portal_district_params)).and_return(false)
        put :update, params: { :id => "37", :portal_district => portal_district_params }
      end

      it "assigns the district as @portal_district" do
        allow(@district).to receive_messages(:update => false)
        allow(Portal::District).to receive(:find).and_return(@district)
        put :update, params: { :id => "1" }
        expect(assigns[:portal_district]).to equal(@district)
      end

      it "re-renders the 'edit' template" do
        allow(@district).to receive_messages(:update => false)
        allow(Portal::District).to receive(:find).and_return(@district)
        put :update, params: { :id => "1" }
        expect(response).to render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested district" do
      expect(@district).to receive(:destroy).and_return(true)
      expect(Portal::District).to receive(:find).with("37").and_return(@district)
      delete :destroy, params: { :id => "37" }
    end

    it "redirects to the portal_districts list" do
      expect(@district).to receive(:destroy).and_return(true)
      allow(Portal::District).to receive(:find).and_return(@district)
      delete :destroy, params: { :id => "1" }
      expect(response).to redirect_to(portal_districts_url(host: 'test.host'))
    end
  end
end
