require File.expand_path('../../../spec_helper', __FILE__)

describe Portal::SchoolsController do
  # render_views

  def mock_school(_stubs={})
    clazzes = mock(:active => [], :length => 0, :size => 0)
    stubs = {
      :name => "school",
      :description => "school description",
      :district => nil,
      :children => [],
      :teacher_only? => false,
      :authorable_in_java? => false,
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
    clazzes = mock(:active => [], :length => 0, :size => 0)
    stubs = {
      :SCHNAM => "AMHERST REGIONAL MS",
      :changeable? => true  # admin user in most test cases..
    }
    stubs.merge!(_stubs)
    nces_mock_school = mock_model(Portal::Nces06School, stubs)
    nces_mock_school
  end
  
  before(:each) do
    generate_default_project_and_jnlps_with_mocks
    generate_portal_resources_with_mocks
    login_admin
    @school = mock_school
    @nces_school = nces_mock_school
    @states_and_provinces = StatesAndProvinces::STATES_AND_PROVINCES.to_a
  end

  describe "GET index" do
    it "assigns all portal_schools as @portal_schools" do
      Portal::School.stub!(:find).with(:all, hash_including(will_paginate_params)).and_return([@school])
      get :index
      assigns[:portal_schools].should == [@school]
    end
  end

  describe "GET show" do
    it "assigns the requested school as @portal_school" do
      Portal::School.stub!(:find).with("37").and_return(@school)
      get :show, :id => "37"
      assigns[:portal_school].should equal(@school)
    end
  end
  
  describe "GET new" do
    it "assigns a new school as @portal_school" do
      Portal::School.stub!(:new).and_return(@school)
      get :new
      assigns[:portal_school].should equal(@school)
    end
  end
  
  describe "GET edit" do
    it "assigns the requested school as @portal_school" do
      #@school.should_receive(:changeable?).and_return(:true)
      Portal::School.stub!(:find).with("37").and_return(@school)
      get :edit, :id => "37"
      assigns[:portal_school].should equal(@school)
    end
  end
  
  describe "POST create" do
  
    describe "with valid nces_school params" do
      it "assigns a newly created school as @portal_school" do
        @school.should_receive(:save).and_return(true)
        Portal::Nces06School.stub!(:find).with('123').and_return(@nces_school)
        Portal::School.stub!(:find_or_create_by_nces_school).with(@nces_school).and_return(@school)
        post :create, :nces_school => {:id => '123'}
        assigns[:portal_school].should equal(@school)
      end
  
      it "redirects to the created school" do
        @school.should_receive(:save).and_return(true)
        Portal::Nces06School.stub!(:find).with('123').and_return(@nces_school)
        Portal::School.stub!(:find_or_create_by_nces_school).with(@nces_school).and_return(@school)
        post :create, :nces_school => {:id => '123'}
        response.should redirect_to(portal_school_url(@school))
      end
    end
  
    describe "with invalid portal_school params" do
      it "assigns a newly created but unsaved school as @portal_school" do
        @school.should_receive(:save).and_return(true)
        Portal::School.stub!(:new).with({'these' => 'params'}).and_return(@school)
        post :create, :portal_school => {:these => 'params'}
        assigns[:portal_school].should equal(@school)
      end
  
      it "re-renders the 'new' template" do
        @school.should_receive(:save).and_return(false)
        Portal::School.stub!(:new).and_return(@school)
        post :create, :portal_school => {}
        response.should render_template('new')
      end
    end
  
  end
  
  describe "PUT update" do
  
    describe "with valid params" do
      it "updates the requested school" do
        Portal::School.should_receive(:find).with("37").and_return(@school)
        @school.should_receive(:update_attributes).with({'portal_school' => 'params'})
        put :update, :id => "37", :portal_school => {:portal_school => 'params'}
      end
  
      it "assigns the requested school as @portal_school" do
        @school.should_receive(:update_attributes).and_return(true)
        Portal::School.stub!(:find).and_return(@school)
        put :update, :id => "1"
        assigns[:portal_school].should equal(@school)
      end
  
      it "redirects to the school" do
        @school.stub!(:id => 1)
        @school.should_receive(:update_attributes).and_return(true)
        Portal::School.stub!(:find).and_return(@school)
        put :update, :id => "1"
        response.should redirect_to(portal_school_url(@school))
      end
    end
  
    describe "with invalid params" do

      before(:each) do
        @school.stub!(:id => 1)
        @school.should_receive(:update_attributes).with({'portal_school' => 'params'}).and_return(false)
        Portal::School.stub!(:find).and_return(@school)
      end

      it "assigns the school as @portal_school" do
        put :update, :id => "1", :portal_school => {:portal_school => 'params'}
        assigns[:portal_school].should equal(@school)
      end
  
      it "re-renders the 'edit' template" do
        put :update, :id => "1", :portal_school => {:portal_school => 'params'}
        response.should render_template('edit')
      end
    end
  
  end
  
  describe "DELETE destroy" do
    render_views

    before(:each) do
      @school.stub!(:id => 1)
      @school.should_receive(:destroy).and_return(true)
      Portal::School.should_receive(:find).with("1").and_return(@school)
    end
    
    it "destroys the requested school" do
      delete :destroy, :id => "1"
    end
  
    it "redirects to the portal_schools list" do
      delete :destroy, :id => "1"
      response.should redirect_to(portal_schools_url)
    end

    it "renders the rjs template" do
      xhr :post, :destroy, :id => "1"
      response.should render_template('destroy')
      response.should have_rjs
    end

    it "the rjs response should remove a dom elemet" do
      xhr :post, :destroy, :id => "1"
      response.should have_rjs(:remove)
    end
  end

end
