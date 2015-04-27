require 'spec_helper'

describe Admin::ProjectsController do

  before(:each) do
    login_admin
  end

  def mock_project(stubs={})
    @mock_project ||= mock_model(Admin::Project, stubs)
  end

  describe "GET index" do
    it "assigns all projects as @projects" do
      Admin::Project.stub(:search).with(nil, nil, nil).and_return([mock_project])
      get :index
      expect(assigns[:projects]).to eql([mock_project])
    end
  end

  describe "GET show" do
    it "assigns the requested projects as @project" do
      Admin::Project.stub(:find).with("37").and_return(mock_project)
      get :show, :id => "37"
      expect(assigns[:project]).to equal(mock_project)
    end
  end

  describe "GET new" do
    it "assigns a new projects as @project" do
      Admin::Project.stub(:new).and_return(mock_project)
      get :new
      expect(assigns[:project]).to equal(mock_project)
    end
  end

  describe "GET edit" do
    it "assigns the requested projects as @project" do
      Admin::Project.stub(:find).with("37").and_return(mock_project)
      get :edit, :id => "37"
      expect(assigns[:project]).to equal(mock_project)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "assigns a newly created projects as @project" do
        Admin::Project.stub(:new).with({'these' => 'params'}).and_return(mock_project(:save => true))
        post :create, :admin_project => {:these => 'params'}
        expect(assigns[:project]).to equal(mock_project)
      end

      it "redirects to the projects list" do
        Admin::Project.stub(:new).and_return(mock_project(:save => true))
        post :create, :admin_project => {}
        expect(response).to redirect_to(admin_projects_url)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved projects as @project" do
        Admin::Project.stub(:new).with({'these' => 'params'}).and_return(mock_project(:save => false))
        post :create, :admin_project => {:these => 'params'}
        expect(assigns[:project]).to equal(mock_project)
      end

      it "re-renders the 'new' template" do
        Admin::Project.stub(:new).and_return(mock_project(:save => false))
        post :create, :admin_project => {}
        expect(response).to render_template('new')
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested project" do
        Admin::Project.should_receive(:find).with("37").and_return(mock_project)
        mock_project.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :admin_project => {:these => 'params'}
      end

      it "assigns the requested projects as @project" do
        Admin::Project.stub(:find).and_return(mock_project(:update_attributes => true))
        put :update, :id => "1"
        expect(assigns[:project]).to equal(mock_project)
      end

      it "redirects to the projects" do
        Admin::Project.stub(:find).and_return(mock_project(:update_attributes => true))
        put :update, :id => "1"
        expect(response).to redirect_to(admin_project_url(mock_project))
      end
    end

    describe "with invalid params" do
      it "updates the requested projects" do
        Admin::Project.should_receive(:find).with("37").and_return(mock_project)
        mock_project.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :admin_project => {:these => 'params'}
      end

      it "assigns the projects as @projects" do
        Admin::Project.stub(:find).and_return(mock_project(:update_attributes => false))
        put :update, :id => "1"
        expect(assigns[:project]).to equal(mock_project)
      end

      it "re-renders the 'edit' template" do
        Admin::Project.stub(:find).and_return(mock_project(:update_attributes => false))
        put :update, :id => "1"
        expect(response).to render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested projects" do
      Admin::Project.should_receive(:find).with("37").and_return(mock_project)
      mock_project.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the projects list" do
      Admin::Project.stub(:find).and_return(mock_project(:destroy => true))
      delete :destroy, :id => "1"
      expect(response).to redirect_to(admin_projects_url)
    end
  end
end
