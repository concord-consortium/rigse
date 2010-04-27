require 'spec_helper'

describe Admin::ProjectsController do

  def mock_project(stubs={})
    @mock_project.stub!(stubs) unless stubs.empty?
    @mock_project
  end

  before(:each) do
    generate_default_project_and_jnlps_with_mocks
    generate_portal_resources_with_mocks
    login_admin
    Admin::Project.should_receive(:default_project).and_return(@mock_project)
  end

  describe "GET index" do
    it "assigns all admin_projects as @admin_projects" do
      Admin::Project.should_receive(:find).with(:all, hash_including(will_paginate_params)).and_return([mock_project])
      get :index
      assigns[:admin_projects].should == [mock_project]
    end
  end

  describe "GET show" do
    it "assigns the requested project as @project" do
      Admin::Project.should_receive(:find).with("37").and_return(mock_project)
      get :show, :id => "37"
      assigns[:admin_project].should equal(mock_project)
    end
  end

  describe "GET new" do
    it "assigns a new project as @project" do
      Admin::Project.should_receive(:new).and_return(mock_project)
      get :new
      assigns[:admin_project].should equal(mock_project)
    end
  end

  describe "GET edit" do
    it "assigns the requested project as @project" do
      Admin::Project.should_receive(:find).with("37").and_return(mock_project)
      get :edit, :id => "37"
      assigns[:admin_project].should equal(mock_project)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created project as @project" do
        Admin::Project.should_receive(:new).with({'these' => 'params'}).and_return(mock_project(:save => true))
        mock_project.should_receive(:save).and_return(mock_project(:save => true))
        post :create, :admin_project => {:these => 'params'}
        assigns[:admin_project].should equal(mock_project)
      end

      it "redirects to the created project" do
        Admin::Project.should_receive(:new).and_return(mock_project(:save => true))
        mock_project.should_receive(:save).and_return(mock_project(:save => true))
        post :create, :admin_project => {}
        response.should redirect_to(admin_project_url(mock_project))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved project as @project" do
        Admin::Project.should_receive(:new).with({'these' => 'params'}).and_return(mock_project(:save => false))
        mock_project.should_receive(:save).and_return(mock_project(:save => false))
        post :create, :admin_project => {:these => 'params'}
        assigns[:admin_project].should equal(mock_project)
      end

      it "re-renders the 'new' template" do
        Admin::Project.should_receive(:new).and_return(mock_project(:save => false))
        mock_project.should_receive(:save).and_return(false)
        post :create, :admin_project => {}
        response.should redirect_to(new_admin_project_url)
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

      it "assigns the requested project as @project" do
        Admin::Project.should_receive(:find).and_return(mock_project(:update_attributes => true))
        mock_project.should_receive(:update_attributes).and_return(mock_project(:save => true))
        put :update, :id => "1"
        assigns[:admin_project].should equal(mock_project)
      end

      it "redirects to the project" do
        Admin::Project.should_receive(:find).and_return(mock_project(:update_attributes => true))
        mock_project.should_receive(:update_attributes).and_return(mock_project(:save => true))
        put :update, :id => "1"
        response.should redirect_to(admin_project_url(mock_project))
      end
    end

    describe "with invalid params" do
      it "updates the requested project" do
        Admin::Project.should_receive(:find).with("37").and_return(mock_project)
        mock_project.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :admin_project => {:these => 'params'}
      end

      it "assigns the project as @project" do
        Admin::Project.should_receive(:find).and_return(mock_project(:update_attributes => false))
        mock_project.should_receive(:update_attributes).and_return(mock_project(:update_attributes => false))
        put :update, :id => "1"
        assigns[:admin_project].should equal(mock_project)
      end

      it "re-renders the 'edit' template" do
        Admin::Project.should_receive(:find).and_return(mock_project(:update_attributes => false))
        mock_project.should_receive(:update_attributes).and_return(mock_project(:update_attributes => false))
        put :update, :id => "1"
        response.should redirect_to(admin_project_url(mock_project))
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
      Admin::Project.should_receive(:find).and_return(mock_project(:destroy => true))
      mock_project.should_receive(:destroy)
      delete :destroy, :id => "1"
      response.should redirect_to(admin_projects_url)
    end
  end

end
