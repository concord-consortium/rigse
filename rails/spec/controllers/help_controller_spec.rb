require 'spec_helper'

describe HelpController, type: :controller do
  
  before(:each) do
      @admin_user = FactoryBot.generate(:admin_user)
      @test_settings = FactoryBot.create(:admin_settings, :user => @admin_user, :id=> 1)
      login_admin
      allow(Admin::Settings).to receive(:default_settings).and_return(@test_settings)
  end
  
  describe "GET index" do
    it "should render no help page template when help type is no help" do
      @test_settings.help_type = 'no help'
      get :index
      expect(response).to render_template('help/no_help_page')
    end
    it "should redirect to external url when help type is external url" do
      @test_settings.external_url = 'www.concord.org'
      @test_settings.help_type = 'external url'
      get :index
      expect(response).to redirect_to 'www.concord.org'
    end
    it "should render index template when help type is help custom html" do
      @test_settings.custom_help_page_html = '<b>Help page</b>'
      @test_settings.help_type = 'help custom html'
      get :index
      expect(assigns[:help_page_content]).to eq('<b>Help page</b>')
      expect(response).to render_template('index')
    end
  end

  describe "POST preview_help_page" do
    it "should set variables with data coming from front end when preview is from edit page" do
      @post_params = {
          :preview_help_page_from_edit => '<b>help page<b>'
        }
      post :preview_help_page, @post_params
      expect(assigns[:help_page_content]).to eq(@post_params[:preview_help_page_from_edit])
      expect(response).to render_template('preview_help_page')
    end
    
    it "should render no help page template when help type is no help and preview is from summary page." do
      @test_settings.help_type = 'no help'
      @test_settings.save!
      @test_settings.reload
      @post_params = {
          :preview_help_page_from_summary_page => "#{@test_settings.id}"
        }
      get :preview_help_page, @post_params
      expect(response).to render_template('help/no_help_page')
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
      expect(response).to redirect_to 'www.concord.org'
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
      expect(assigns[:help_page_content]).to eq('<b>Help page</b>')
      expect(response).to render_template('preview_help_page')
    end
    
  end
end
