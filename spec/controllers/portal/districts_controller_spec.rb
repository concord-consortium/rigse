require 'spec_helper'

describe Portal::DistrictsController do
  integrate_views  
  def mock_district(_stubs={})
    stubs = {
      :name => 'default district', 
      :description => 'default district',
      :changeable? => :flase, 
      :authorable_in_java? => false,
      :schools => [],
      :nces_district_id => nil
    }
    stubs.merge!(_stubs)
    @mock_district = mock_model(Portal::District, stubs)
    @mock_district
  end

  before(:each) do
    generate_default_project_and_jnlps_with_mocks
    generate_portal_resources_with_mocks
    login_admin
    @district = mock_district 
  end

  describe "GET index" do
    it "assigns all portal_districts as @portal_districts" do
      Portal::District.stub!(:find).with(:all, hash_including(will_paginate_params)).and_return([@district])
      get :index
      assigns[:portal_districts].should include @district
    end
  end

  describe "GET show" do
    it "assigns the requested district as @portal_district" do
      Portal::District.stub!(:find).with("37").and_return(@district)
      get :show, :id => "37"
      assigns[:portal_district].should equal(@district)
    end
  end
  
  describe "GET new" do
    it "assigns a new district as @portal_district" do
      Portal::District.stub!(:new).and_return(@district)
      get :new
      assigns[:portal_district].should equal(@district)
    end
  end
  
  describe "GET edit" do
    it "assigns the requested district as @portal_district" do
      Portal::District.stub!(:find).with("37").and_return(@district)
      get :edit, :id => "37"
      assigns[:portal_district].should equal(@district)
    end
  end
  
  describe "POST create" do
  
    describe "with valid params" do
      it "assigns a newly created district as @portal_district" do
        @district.stub(:save => true)
        Portal::District.stub!(:new).with({'these' => 'params'}).and_return(@district)
        post :create, :portal_district => {:these => 'params'}
        assigns[:portal_district].should equal(@district)
      end
  
      it "redirects to the created district" do
        @district.stub(:id => 37, :save => true )
        Portal::District.stub!(:new).and_return(@district)
        post :create, :portal_district => {}
        response.should redirect_to(portal_district_url(@district))
      end
    end
  
    describe "with invalid params" do
      it "assigns a newly created but unsaved district as @portal_district" do
        @district.stub!(:save => false)
        Portal::District.stub!(:new).with({'these' => 'params'}).and_return(@district)
        post :create, :portal_district => {:these => 'params'}
        assigns[:portal_district].should equal(@district)
      end
  
      it "re-renders the 'new' template" do
        @district.stub!(:save => false)
        Portal::District.stub!(:new).and_return(@district)
        post :create, :portal_district => {}
        response.should render_template('new')
      end
   end
  
  end
 
  describe "PUT update" do
  
    describe "with valid params" do
      it "updates the requested district" do
        Portal::District.should_receive(:find).with("37").and_return(@district)
        @mock_district.should_receive(:update_attributes).with({'portal_district' => 'params'}).and_return(true)
        put :update, :id => "37", :portal_district => {:portal_district => 'params'}
      end
  
      it "assigns the requested district as @portal_district" do
        @district.stub!(:update_attributes => true)
        Portal::District.stub!(:find).and_return(@district)
        put :update, :id => "1"
        assigns[:portal_district].should equal(@district)
      end
  
      it "redirects to the district" do
        @district.stub!(:update_attributes => true)
        Portal::District.stub!(:find).and_return(@district)
        put :update, :id => "1"
        response.should redirect_to(portal_district_url(@district))
      end
    end
  
    describe "with invalid params" do
      it "updates the requested district" do
        Portal::District.should_receive(:find).with("37").and_return(@district)
        @district.should_receive(:update_attributes).with({'portal_district' => 'params'}).and_return(false)
        put :update, :id => "37", :portal_district => {:portal_district => 'params'}
      end
  
      it "assigns the district as @portal_district" do
        @district.stub!(:update_attributes => false)
        Portal::District.stub!(:find).and_return(@district)
        put :update, :id => "1"
        assigns[:portal_district].should equal(@district)
      end
  
      it "re-renders the 'edit' template" do
        @district.stub!(:update_attributes => false)
        Portal::District.stub!(:find).and_return(@district)
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end
 
  end
  
  describe "DELETE destroy" do
    it "destroys the requested district" do
      @district.should_receive(:destroy).and_return(true)
      Portal::District.should_receive(:find).with("37").and_return(@district)
      delete :destroy, :id => "37"
    end
  
    it "redirects to the portal_districts list" do
      @district.should_receive(:destroy).and_return(true)
      Portal::District.stub!(:find).and_return(@district)
      delete :destroy, :id => "1"
      response.should redirect_to(portal_districts_url)
    end
  end

end
