require 'spec_helper'

describe HelpController do
  
  before(:each) do
      @admin_user = Factory.next(:admin_user)
      @test_project = Factory.create(:admin_project_no_jnlps, :user => @admin_user)
      stub_current_user :admin_user
      Admin::Project.stub(:default_project).and_return(@test_project)
  end
  
  describe "GET index" do
    it "should redirect to root when help type is no help" do
      @test_project.help_type = 'no help'
      get :index
      response.should redirect_to :root
    end
    it "should redirect to external url when help type is external url" do
      @test_project.external_url = 'www.concord.org'
      @test_project.help_type = 'external url'
      get :index
      response.should redirect_to 'www.concord.org'
    end
    it "should redirect to external url when help type is external url" do
      @test_project.custom_help_page_html = '<b>Help page</b>'
      @test_project.help_type = 'help custom html'
      get :index
      assert_equal assigns[:help_page_content], '<b>Help page</b>'
      assert_template 'index'
    end
  end
  
  describe "POST preview_help_page" do
    it "should set variables with data coming from front end when preview is from edit page" do
      @post_params = {
          :preview_help_page_from_edit => '<b>help page<b>'
        }
      post :preview_help_page, @post_params
      assert_equal assigns[:help_page_preview_content], @post_params[:preview_help_page_from_edit]
      assert_template 'preview_help_page'
    end
    
    it "should redirect to root when help type is no help and preview is from summary page." do
      @test_project.help_type = 'no help'
      get :preview_help_page
      response.should redirect_to :root
    end
    
    it "should redirect to external url when help type is external url and preview is from summary page." do
      @test_project.external_url = 'www.concord.org'
      @test_project.help_type = 'external url'
      get :preview_help_page
      response.should redirect_to 'www.concord.org'
    end
    
    it "should redirect to external url when help type is external url and preview is from summary page." do
      @test_project.custom_help_page_html = '<b>Help page</b>'
      @test_project.help_type = 'help custom html'
      get :preview_help_page
      assert_equal assigns[:help_page_preview_content], '<b>Help page</b>'
      assert_template 'preview_help_page'
    end
  end
end
