require 'spec_helper'

describe HelpController do
  
  before(:each) do
      @admin_user = Factory.next(:admin_user)
      @test_settings = Factory.create(:admin_settings, :user => @admin_user, :id=> 1)
      login_admin
      Admin::Settings.stub(:default_settings).and_return(@test_settings)
  end
  
  describe "GET index" do
    it "should render no help page template when help type is no help" do
      @test_settings.help_type = 'no help'
      get :index
      assert_template 'help/no_help_page'
    end
    it "should redirect to external url when help type is external url" do
      @test_settings.external_url = 'www.concord.org'
      @test_settings.help_type = 'external url'
      get :index
      response.should redirect_to 'www.concord.org'
    end
    it "should render index template when help type is help custom html" do
      @test_settings.custom_help_page_html = '<b>Help page</b>'
      @test_settings.help_type = 'help custom html'
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
      assert_equal assigns[:help_page_content], @post_params[:preview_help_page_from_edit]
      assert_template 'preview_help_page'
    end
    
    it "should render no help page template when help type is no help and preview is from summary page." do
      @test_settings.help_type = 'no help'
      @test_settings.save!
      @test_settings.reload
      @post_params = {
          :preview_help_page_from_summary_page => "#{@test_settings.id}"
        }
      get :preview_help_page, @post_params
      assert_template 'help/no_help_page'
    end
    
    it "should redirect to external url when help type is external url and preview is from summary page." do
      @test_settings.external_url = 'www.concord.org'
      @test_settings.help_type = 'external url'
      @test_settings.save!
      @test_settings.reload
      @post_params = {
          :preview_help_page_from_summary_page => "#{@test_settings.id}"
        }
      get :preview_help_page, @post_params
      response.should redirect_to 'www.concord.org'
    end
    
    it "should render preview_help_page template when help type is help custom html and preview is from summary page." do
      @test_settings.custom_help_page_html = '<b>Help page</b>'
      @test_settings.help_type = 'help custom html'
      @test_settings.save!
      @test_settings.reload
      @post_params = {
          :preview_help_page_from_summary_page => "#{@test_settings.id}"
        }
      get :preview_help_page, @post_params
      assert_equal assigns[:help_page_content], '<b>Help page</b>'
      assert_template 'preview_help_page'
    end
    
  end
end
