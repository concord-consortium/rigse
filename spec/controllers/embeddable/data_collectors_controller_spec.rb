require 'spec_helper'

describe Embeddable::DataCollectorsController do
  integrate_views

  before(:each) do
    generate_mock_project_and_jnlps
    @data_collector ||= Factory.create(:data_collector)
    login_admin
    @session_options = {
      :secure=>false, 
      :secret=>"924cdf373582bbc17ac32060921e6f028a996bb85bbb4b4d7d8cb8c98ef18615a793e676e511e0143708ee7c243c89605bcfdfaa339ed649e58e2fbd6498e117", 
      :expire_after=>nil, 
      :path=>"/", 
      :httponly=>true, 
      :domain=>nil, 
      :key=>"_bort_session", 
      :id=>"a0fbca97e9dce0e19ec94ff9afb62b8e", 
      :cookie_only=>true
    }
    request.env['rack.session.options'] = @session_options    
  end
  

  describe "GET index" do
    it "runs without error" do
      get :index
      response.should be_success
    end
  end

  describe "GET show" do
    it "assigns the requested data_collector as @data_collector" do
      Embeddable::DataCollector.stub!(:find).with("37").and_return(@data_collector)
      get :show, :id => "37"
      assigns[:data_collector].should equal(@data_collector)
    end
    
    describe "with mime type of otml" do
    
      it "renders the requested data_collector as otml without error" do
        Embeddable::DataCollector.stub!(:find).with("37").and_return(@data_collector)
        get :show, :id => "37", :format => 'otml'
        assigns[:data_collector].should equal(@data_collector)
      end
    
    end
    
    describe "with mime type of dynamic_otml" do
    
      it "renders the requested data_collector as dynamic_otml without error" do
        Embeddable::DataCollector.stub!(:find).with("37").and_return(@data_collector)
        get :show, :id => "37", :format => 'dynamic_otml'
        assigns[:data_collector].should equal(@data_collector)
      end
    
    end
    
    describe "with mime type of config" do
    
      it "renders the requested data_collector as config without error" do
        Embeddable::DataCollector.stub!(:find).with("37").and_return(@data_collector)
        get :show, :id => "37", :format => 'config'
        assigns[:data_collector].should equal(@data_collector)
      end
    
    end
    
    describe "with mime type of jnlp" do
    
      it "renders the requested data_collector as jnlp without error" do
        Embeddable::DataCollector.stub!(:find).with("37").and_return(@data_collector)
        get :show, :id => "37", :format => 'jnlp'
        assigns[:data_collector].should equal(@data_collector)
      end
    
    end
    
  end

  describe "GET edit" do
    it "assigns the requested data_collector as @data_collector" do
      Embeddable::DataCollector.stub!(:find).with("37").and_return(@data_collector)
      get :edit, :id => "37"
      assigns[:data_collector].should equal(@data_collector)
    end
    
    describe "with mime type of otml" do

      it "renders the requested data_collector as otml without error" do
        Embeddable::DataCollector.stub!(:find).with("37").and_return(@data_collector)
        get :edit, :id => "37", :format => 'otml'
        assigns[:data_collector].should equal(@data_collector)
        response.should render_template(:edit)
        response.should have_tag('otrunk') do
          with_tag('imports')
          with_tag('objects') do
            with_tag('OTSystem') do
              with_tag('bundles')
              with_tag('root')
              with_tag('library') do
                with_tag('OTDataCollector') do
                  with_tag('source')
                  with_tag('xDataAxis')
                  with_tag('yDataAxis')
                end
              end
            end
          end
        end
      end    
    end
    
    describe "with mime type of dynamic_otml" do
    
      it "renders the requested data_collector as dynamic_otml without error" do
        Embeddable::DataCollector.stub!(:find).with("37").and_return(@data_collector)
        get :edit, :id => "37", :format => 'dynamic_otml', :session => '6ee4ff32b48026db6f3758da9f090150'
        assigns[:data_collector].should equal(@data_collector)
        response.should render_template("shared/_show.dynamic_otml.builder")
        response.should have_tag('otrunk') do
          with_tag('imports')
          with_tag('objects') do
            with_tag('OTSystem') do
              with_tag('includes')
              with_tag('bundles')
              with_tag('overlays')
              with_tag('root')
            end
          end
        end
      end
    
    end
    
    describe "with mime type of config" do
    
      it "renders the requested data_collector as config without error" do
        Embeddable::DataCollector.stub!(:find).with("37").and_return(@data_collector)
        get :edit, :id => "37", :format => 'config', :session => '6ee4ff32b48026db6f3758da9f090150'
        assigns[:data_collector].should equal(@data_collector)
        response.should render_template("shared/_show.config.builder")
        response.should have_tag('java') do
          with_tag('object')
        end
      end
    
    end
    
    describe "with mime type of jnlp" do
    
      it "renders the requested data_collector as jnlp without error" do
        Embeddable::DataCollector.stub!(:find).with("37").and_return(@data_collector)
        get :edit, :id => "37", :format => 'jnlp'
        assigns[:data_collector].should equal(@data_collector)
        response.should render_template("shared/_edit.jnlp.haml")
        response.should have_tag('jnlp') do
          with_tag('information')
          with_tag('security')
          with_tag('resources')
          with_tag('application-desc') do
            with_tag('argument')
          end
        end
      end
    
    end
    
  end


end
