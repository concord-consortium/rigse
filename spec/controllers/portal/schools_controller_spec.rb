require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../spec_controller_helper')

describe Portal::SchoolsController do

  def mock_school(stubs={})
    @mock_school ||= mock_model(Portal::School, stubs)
    # @mock_school.stub!(:update_attributes => true)
  end
  
  before(:each) do
    #mock_project  #FIXME: mock_project is undefined!
    Admin::Project.should_receive(:default_project).and_return(@mock_project)
  end

  describe "GET index" do
    it "assigns all portal_schools as @portal_schools" do
      pending "Broken example"
      Portal::School.stub!(:find).with(:all).and_return([mock_school])
      get :index
      assigns[:portal_schools].should == [mock_school]
    end
  end

  describe "GET show" do
    it "assigns the requested school as @school" do
      pending "Broken example"
      Portal::School.stub!(:find).with("37").and_return(mock_school)
      get :show, :id => "37"
      assigns[:school].should equal(mock_school)
    end
  end

  describe "GET new" do
    it "assigns a new school as @school" do
      pending "Broken example"
      Portal::School.stub!(:new).and_return(mock_school)
      get :new
      assigns[:school].should equal(mock_school)
    end
  end

  describe "GET edit" do
    it "assigns the requested school as @school" do
      pending "Broken example"
      Portal::School.stub!(:find).with("37").and_return(mock_school)
      get :edit, :id => "37"
      assigns[:school].should equal(mock_school)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created school as @school" do
        pending "Broken example"
        Portal::School.stub!(:new).with({'these' => 'params'}).and_return(mock_school(:save => true))
        post :create, :school => {:these => 'params'}
        assigns[:school].should equal(mock_school)
      end

      it "redirects to the created school" do
        pending "Broken example"
        Portal::School.stub!(:new).and_return(mock_school(:save => true))
        post :create, :school => {}
        response.should redirect_to(portal_school_url(mock_school))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved school as @school" do
        pending "Broken example"
        Portal::School.stub!(:new).with({'these' => 'params'}).and_return(mock_school(:save => false))
        post :create, :school => {:these => 'params'}
        assigns[:school].should equal(mock_school)
      end

      it "re-renders the 'new' template" do
        pending "Broken example"
        Portal::School.stub!(:new).and_return(mock_school(:save => false))
        post :create, :school => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested school" do
        pending "Broken example"
        Portal::School.should_receive(:find).with("37").and_return(mock_school)
        mock_school.should_receive(:update_attributes).with({'portal_school' => 'params'})
        put :update, :id => "37", :school => {:portal_school => 'params'}
      end

      it "assigns the requested school as @school" do
        pending "Broken example"
        Portal::School.stub!(:find).and_return(mock_school(:update_attributes => true))
        put :update, :id => "1"
        assigns[:school].should equal(mock_school)
      end

      it "redirects to the school" do
        pending "Broken example"
        Portal::School.stub!(:find).and_return(mock_school(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(portal_school_url(mock_school))
      end
    end

    describe "with invalid params" do
      it "updates the requested school" do
        pending "Broken example"
        Portal::School.should_receive(:find).with("37").and_return(mock_school)
        mock_school.should_receive(:update_attributes).with({'portal_school' => 'params'})
        put :update, :id => "37", :school => {:portal_school => 'params'}
      end

      it "assigns the school as @school" do
        pending "Broken example"
        Portal::School.stub!(:find).and_return(mock_school(:update_attributes => false))
        put :update, :id => "1"
        assigns[:school].should equal(mock_school)
      end

      it "re-renders the 'edit' template" do
        pending "Broken example"
        Portal::School.stub!(:find).and_return(mock_school(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested school" do
      pending "Broken example"
      Portal::School.should_receive(:find).with("37").and_return(mock_school)
      mock_school.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the portal_schools list" do
      pending "Broken example"
      Portal::School.stub!(:find).and_return(mock_school(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(portal_schools_url)
    end
  end

end
