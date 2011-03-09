require 'spec_helper'

describe Portal::ExternalUsersController do

  def mock_external_user(stubs={})
     # @mock_external_user ||= mock_model(ExternalUser, stubs)
     @mock_external_user.stub!(stubs) unless stubs.empty?
     @mock_external_user
   end

   before(:each) do
     generate_default_project_and_jnlps_with_factories
     generate_portal_resources_with_mocks
     login_admin
     #Admin::Project.should_receive(:default_project).and_return(@mock_project)
   end

   describe "GET index" do
     it "assigns all portal_external_users as @portal_external_users" do
       ExternalUser.stub!(:find).with(:all).and_return([mock_external_user])
       get :index
       assigns[:portal_external_users].should == [mock_external_user]
     end
   end

   describe "GET show" do
     it "assigns the requested external_user as @portal_external_user" do
       ExternalUser.stub!(:find).with("37").and_return(mock_external_user)
       get :show, :id => "37"
       assigns[:portal_external_user].should equal(mock_external_user)
     end
   end

   describe "GET new" do
     it "assigns a new external_user as @portal_external_user" do
       ExternalUser.stub!(:new).and_return(mock_external_user)
       get :new
       assigns[:portal_external_user].should equal(mock_external_user)
     end
   end

   describe "GET edit" do
     it "assigns the requested external_user as @portal_external_user" do
       ExternalUser.stub!(:find).with("37").and_return(mock_external_user)
       get :edit, :id => "37"
       assigns[:portal_external_user].should equal(mock_external_user)
     end
   end

   describe "POST create" do

     describe "with valid params" do
       it "assigns a newly created external_user as @portal_external_user" do
         pending "Broken example"
         ExternalUser.stub!(:new).with({'these' => 'params'}).and_return(mock_external_user(:save => true))
         post :create, :portal_external_user => {:these => 'params'}
         assigns[:portal_external_user].should equal(mock_external_user)
       end

       it "redirects to the created external_user" do
         pending "Broken example"
         ExternalUser.should_receive(:new).and_return(mock_external_user(:save => true))
         post :create, :portal_external_user => {}
         response.should redirect_to(portal_external_user_url(mock_external_user))
       end
     end

     describe "with invalid params" do
       it "assigns a newly created but unsaved external_user as @portal_external_user" do
         pending "Broken example"
         ExternalUser.should_receive(:new).with({'these' => 'params'}).and_return(mock_external_user(:save => false))
         post :create, :portal_external_user => {:these => 'params'}
         assigns[:portal_external_user].should equal(mock_external_user)
       end

       it "re-renders the 'new' template" do
         ExternalUser.should_receive(:new).and_return(mock_external_user(:save => false))
         post :create, :portal_external_user => {}
         response.should render_template('new')
       end
     end

   end

   describe "PUT update" do

     describe "with valid params" do
       it "updates the requested external_user" do
         pending "Broken example"
         ExternalUser.should_receive(:find).with("37").and_return(mock_external_user)
         mock_external_user.should_receive(:update_attributes).with({'these' => 'params'})
         put :update, :id => "37", :portal_external_user => {:these => 'params'}
       end

       it "assigns the requested external_user as @portal_external_user" do
         pending "Broken example"
         ExternalUser.should_receive(:find).and_return(mock_external_user(:update_attributes => true))
         put :update, :id => "1"
         assigns[:portal_external_user].should equal(mock_external_user)
       end

       it "redirects to the external_user" do
         pending "Broken example"
         ExternalUser.stub!(:find).and_return(mock_external_user(:update_attributes => true))
         put :update, :id => "1"
         response.should redirect_to(portal_external_user_url(mock_external_user))
       end
     end

     describe "with invalid params" do
       it "updates the requested external_user" do
         pending "Broken example"
         ExternalUser.should_receive(:find).with("37").and_return(mock_external_user)
         mock_external_user.should_receive(:update_attributes).with({'these' => 'params'})
         put :update, :id => "37", :portal_external_user => {:these => 'params'}
       end

       it "assigns the external_user as @portal_external_user" do
         pending "Broken example"
         ExternalUser.stub!(:find).and_return(mock_external_user(:update_attributes => false))
         put :update, :id => "1"
         assigns[:portal_external_user].should equal(mock_external_user)
       end

       it "re-renders the 'edit' template" do
         pending "Broken example"
         ExternalUser.stub!(:find).and_return(mock_external_user(:update_attributes => false))
         put :update, :id => "1"
         response.should render_template('edit')
       end
     end

   end

   describe "DELETE destroy" do
     it "destroys the requested external_user" do
       pending "Broken example"
       ExternalUser.should_receive(:find).with("37").and_return(mock_external_user)
       mock_external_user.should_receive(:destroy)
       delete :destroy, :id => "37"
     end

     it "redirects to the portal_external_users list" do
       pending "Broken example"
       ExternalUser.stub!(:find).and_return(mock_external_user(:destroy => true))
       delete :destroy, :id => "1"
       response.should redirect_to(portal_external_users_url)
     end
   end
end
