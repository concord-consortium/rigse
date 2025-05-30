require File.expand_path('../../../spec_helper', __FILE__)

describe Portal::SchoolsController do
  # render_views

  let(:portal_school_params) {{
    "city" => "Testertown", "country_id" => "1", "description" => "Test School", "district_id" => "2",
    "name" => "Testertown School", "nces_school_id" => "3", "ncessch" => "test", "state" => "MA",
    "zipcode" => "01234"
  }}

  def mock_school(_stubs={})
    clazzes = double(:active => [], :length => 0, :size => 0)
    stubs = {
      :name => "school",
      :description => "school description",
      :district => nil,
      :children => [],
      :teacher_only? => false,
      :district_id => nil,
      :nces_school_id => nil,
      :clazzes => clazzes,
      :changeable? => true  # admin user in most test cases..
    }
    stubs.merge!(_stubs)
    mock_school = mock_model(Portal::School,stubs)
    mock_school
  end

  def nces_mock_school(_stubs={})
    clazzes = double(:active => [], :length => 0, :size => 0)
    stubs = {
      :SCHNAM => "AMHERST REGIONAL MS",
      :changeable? => true  # admin user in most test cases..
    }
    stubs.merge!(_stubs)
    nces_mock_school = mock_model(Portal::Nces06School, stubs)
    nces_mock_school
  end

  before(:each) do
    generate_default_settings_with_mocks
    generate_portal_resources_with_mocks
    login_admin
    @school = mock_school
    @nces_school = nces_mock_school
    @states_and_provinces = ['KS', 'MA']
  end

  describe "GET index" do
    it "assigns all portal_schools as @portal_schools" do
      allow(Portal::School).to receive(:search).with(nil,nil,nil).and_return([@school])
      get :index
      expect(assigns[:portal_schools]).to eq([@school])
    end
  end

  describe "GET show" do
    it "assigns the requested school as @portal_school" do
      allow(Portal::School).to receive(:find).with("37").and_return(@school)
      get :show, params: { :id => "37" }
      expect(assigns[:portal_school]).to equal(@school)
    end
  end

  describe "GET new" do
    it "assigns a new school as @portal_school" do
      allow(Portal::School).to receive(:new).and_return(@school)
      get :new
      expect(assigns[:portal_school]).to equal(@school)
    end
  end

  describe "GET edit" do
    it "assigns the requested school as @portal_school" do
      #@school.should_receive(:changeable?).and_return(:true)
      allow(Portal::School).to receive(:find).with("37").and_return(@school)
      get :edit, params: { :id => "37" }
      expect(assigns[:portal_school]).to equal(@school)
    end
  end

  describe "POST create" do

    describe "with valid nces_school params" do
      it "assigns a newly created school as @portal_school" do
        expect(@school).to receive(:save).and_return(true)
        allow(Portal::Nces06School).to receive(:find).with('123').and_return(@nces_school)
        allow(Portal::School).to receive(:find_or_create_using_nces_school).with(@nces_school).and_return(@school)
        post :create, params: { :nces_school => {:id => '123'} }
        expect(assigns[:portal_school]).to equal(@school)
      end

      it "redirects to the created school" do
        expect(@school).to receive(:save).and_return(true)
        allow(Portal::Nces06School).to receive(:find).with('123').and_return(@nces_school)
        allow(Portal::School).to receive(:find_or_create_using_nces_school).with(@nces_school).and_return(@school)
        post :create, params: { :nces_school => {:id => '123'} }
        expect(response).to redirect_to(portal_school_url(@school, host: 'test.host'))
      end
    end

    describe "with invalid portal_school params" do
      it "assigns a newly created but unsaved school as @portal_school" do
        expect(@school).to receive(:save).and_return(true)
        allow(Portal::School).to receive(:new).with(permit_params!(portal_school_params)).and_return(@school)
        post :create, params: { :portal_school => portal_school_params }
        expect(assigns[:portal_school]).to equal(@school)
      end

      it "re-renders the 'new' template" do
        expect(@school).to receive(:save).and_return(false)
        allow(Portal::School).to receive(:new).and_return(@school)
        post :create, params: { :portal_school => {} }
        expect(response).to render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested school" do
        expect(Portal::School).to receive(:find).with("37").and_return(@school)
        expect(@school).to receive(:update).with(permit_params!(portal_school_params))
        put :update, params: { :id => "37", :portal_school => portal_school_params }
      end

      it "assigns the requested school as @portal_school" do
        expect(@school).to receive(:update).and_return(true)
        allow(Portal::School).to receive(:find).and_return(@school)
        put :update, params: { :id => "1" }
        expect(assigns[:portal_school]).to equal(@school)
      end

      it "redirects to the school" do
        allow(@school).to receive_messages(:id => 1)
        expect(@school).to receive(:update).and_return(true)
        allow(Portal::School).to receive(:find).and_return(@school)
        put :update, params: { :id => "1" }
        expect(response).to redirect_to(portal_schools_url(host: 'test.host'))
      end
    end

    describe "with invalid params" do

      before(:each) do
        allow(@school).to receive_messages(:id => 1)
        expect(@school).to receive(:update).with(permit_params!(portal_school_params)).and_return(false)
        allow(Portal::School).to receive(:find).and_return(@school)
      end

      it "assigns the school as @portal_school" do
        put :update, params: { :id => "1", :portal_school => portal_school_params }
        expect(assigns[:portal_school]).to equal(@school)
      end

      it "re-renders the 'edit' template" do
        put :update, params: { :id => "1", :portal_school => portal_school_params }
        expect(response).to render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    render_views

    before(:each) do
      allow(@school).to receive_messages(:id => 1)
      expect(@school).to receive(:destroy).and_return(true)
      expect(Portal::School).to receive(:find).with("1").and_return(@school)
    end

    it "destroys the requested school" do
      delete :destroy, params: { :id => "1" }
    end

    it "redirects to the portal_schools list" do
      delete :destroy, params: { :id => "1" }
      expect(response).to redirect_to(portal_schools_url(host: 'test.host'))
    end

  end
end
