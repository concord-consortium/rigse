require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../spec_controller_helper')

describe Admin::ProjectsController do

  def mock_project(stubs={})
    @mock_project ||= mock_model(Admin::Project, stubs)
  end

  describe "GET index" do
    it "assigns all admin_projects as @admin_projects" do
      Admin::Project.stub!(:find).with(:all).and_return([mock_project])
      get :index
      assigns[:admin_projects].should == [mock_project]
    end
  end

  describe "GET show" do
    it "assigns the requested project as @project" do
      Admin::Project.stub!(:find).with("37").and_return(mock_project)
      get :show, :id => "37"
      assigns[:project].should equal(mock_project)
    end
  end

  describe "GET new" do
    it "assigns a new project as @project" do
      Admin::Project.stub!(:new).and_return(mock_project)
      get :new
      assigns[:project].should equal(mock_project)
    end
  end

  describe "GET edit" do
    it "assigns the requested project as @project" do
      Admin::Project.stub!(:find).with("37").and_return(mock_project)
      get :edit, :id => "37"
      assigns[:project].should equal(mock_project)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created project as @project" do
        Admin::Project.stub!(:new).with({'these' => 'params'}).and_return(mock_project(:save => true))
        post :create, :project => {:these => 'params'}
        assigns[:project].should equal(mock_project)
      end

      it "redirects to the created project" do
        Admin::Project.stub!(:new).and_return(mock_project(:save => true))
        post :create, :project => {}
        response.should redirect_to(admin_project_url(mock_project))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved project as @project" do
        Admin::Project.stub!(:new).with({'these' => 'params'}).and_return(mock_project(:save => false))
        post :create, :project => {:these => 'params'}
        assigns[:project].should equal(mock_project)
      end

      it "re-renders the 'new' template" do
        Admin::Project.stub!(:new).and_return(mock_project(:save => false))
        post :create, :project => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested project" do
        Admin::Project.should_receive(:find).with("37").and_return(mock_project)
        mock_project.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :project => {:these => 'params'}
      end

      it "assigns the requested project as @project" do
        Admin::Project.stub!(:find).and_return(mock_project(:update_attributes => true))
        put :update, :id => "1"
        assigns[:project].should equal(mock_project)
      end

      it "redirects to the project" do
        Admin::Project.stub!(:find).and_return(mock_project(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(admin_project_url(mock_project))
      end
    end

    describe "with invalid params" do
      it "updates the requested project" do
        Admin::Project.should_receive(:find).with("37").and_return(mock_project)
        mock_project.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :project => {:these => 'params'}
      end

      it "assigns the project as @project" do
        Admin::Project.stub!(:find).and_return(mock_project(:update_attributes => false))
        put :update, :id => "1"
        assigns[:project].should equal(mock_project)
      end

      it "re-renders the 'edit' template" do
        Admin::Project.stub!(:find).and_return(mock_project(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested project" do
      Admin::Project.should_receive(:find).with("37").and_return(mock_project)
      mock_project.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the admin_projects list" do
      Admin::Project.stub!(:find).and_return(mock_project(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(admin_projects_url)
    end
  end

end
