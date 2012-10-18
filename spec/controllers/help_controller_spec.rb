require 'spec_helper'

describe HelpController do
  
  describe "GET index" do
    it "should set variables to view help page" do
      @admin_user = Factory.next(:admin_user)
      stub_current_user :admin_user
      admin_project = Factory.create(:admin_project, :help_type => 'help custom html', :custom_help_page_html => '<b>Help page</b>', :active => true)
      get :index
      assert_equal assigns[:help_page_content], '<b>Help page</b>'
    end
  end
  describe "POST preview_help_page" do
    it "should set variables to preview help page" do
      @admin_user = Factory.next(:admin_user)
      stub_current_user :admin_user
      admin_project = Factory.create(:admin_project, :help_type => 'help custom html', :custom_help_page_html => '<b>Help page</b>', :active => true)
      @post_params = {
          :preview_help_page_content => '<b>help page<b>'
        }
      post :preview_help_page, @post_params
      assert_equal assigns[:help_page_preview_content], @post_params[:preview_help_page_content]
    end
  end
end
