require File.expand_path('../../../spec_helper', __FILE__)

describe MavenJnlp::IconsController do

  def mock_icon(stubs={})
    @mock_icon ||= mock_model(MavenJnlp::Icon, stubs)
  end

  before(:each) do
    generate_default_project_and_jnlps_with_mocks
    logout_user
  end

  describe "GET index" do

    it "exposes all maven_jnlp_icons as @maven_jnlp_icons" do
      MavenJnlp::Icon.should_receive(:find).with(:all).and_return([mock_icon])
      get :index
      assigns[:maven_jnlp_icons].should == [mock_icon]
    end

    describe "with mime type of xml" do
  
      it "renders all maven_jnlp_icons as xml" do
        MavenJnlp::Icon.should_receive(:find).with(:all).and_return(icons = mock("Array of MavenJnlp::Icons"))
        icons.should_receive(:to_xml).and_return("generated XML")
        get :index, :format => 'xml'
        response.body.should == "generated XML"
      end
    
    end

  end

  describe "GET show" do

    it "exposes the requested icon as @icon" do
      MavenJnlp::Icon.should_receive(:find).with("37").and_return(mock_icon)
      get :show, :id => "37"
      assigns[:icon].should equal(mock_icon)
    end
    
    describe "with mime type of xml" do

      it "renders the requested icon as xml" do
        MavenJnlp::Icon.should_receive(:find).with("37").and_return(mock_icon)
        mock_icon.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37", :format => 'xml'
        response.body.should == "generated XML"
      end

    end
    
  end

  describe "GET new" do
  
    it "exposes a new icon as @icon" do
      MavenJnlp::Icon.should_receive(:new).and_return(mock_icon)
      get :new
      assigns[:icon].should equal(mock_icon)
    end

  end

  describe "GET edit" do
  
    it "exposes the requested icon as @icon" do
      MavenJnlp::Icon.should_receive(:find).with("37").and_return(mock_icon)
      get :edit, :id => "37"
      assigns[:icon].should equal(mock_icon)
    end

  end

  describe "POST create" do

    describe "with valid params" do
      
      it "exposes a newly created icon as @icon" do
        MavenJnlp::Icon.should_receive(:new).with({'these' => 'params'}).and_return(mock_icon(:save => true))
        post :create, :icon => {:these => 'params'}
        assigns(:icon).should equal(mock_icon)
      end

      it "redirects to the created icon" do
        MavenJnlp::Icon.stub!(:new).and_return(mock_icon(:save => true))
        post :create, :icon => {}
        response.should redirect_to(maven_jnlp_icon_url(mock_icon))
      end
      
    end
    
    describe "with invalid params" do

      it "exposes a newly created but unsaved icon as @icon" do
        MavenJnlp::Icon.stub!(:new).with({'these' => 'params'}).and_return(mock_icon(:save => false))
        post :create, :icon => {:these => 'params'}
        assigns(:icon).should equal(mock_icon)
      end

      it "re-renders the 'new' template" do
        MavenJnlp::Icon.stub!(:new).and_return(mock_icon(:save => false))
        post :create, :icon => {}
        response.should render_template('new')
      end
      
    end
    
  end

  describe "PUT udpate" do

    describe "with valid params" do

      it "updates the requested icon" do
        MavenJnlp::Icon.should_receive(:find).with("37").and_return(mock_icon)
        mock_icon.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :icon => {:these => 'params'}
      end

      it "exposes the requested icon as @icon" do
        MavenJnlp::Icon.stub!(:find).and_return(mock_icon(:update_attributes => true))
        put :update, :id => "1"
        assigns(:icon).should equal(mock_icon)
      end

      it "redirects to the icon" do
        MavenJnlp::Icon.stub!(:find).and_return(mock_icon(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(maven_jnlp_icon_url(mock_icon))
      end

    end
    
    describe "with invalid params" do

      it "updates the requested icon" do
        MavenJnlp::Icon.should_receive(:find).with("37").and_return(mock_icon)
        mock_icon.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :icon => {:these => 'params'}
      end

      it "exposes the icon as @icon" do
        MavenJnlp::Icon.stub!(:find).and_return(mock_icon(:update_attributes => false))
        put :update, :id => "1"
        assigns(:icon).should equal(mock_icon)
      end

      it "re-renders the 'edit' template" do
        MavenJnlp::Icon.stub!(:find).and_return(mock_icon(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "DELETE destroy" do

    it "destroys the requested icon" do
      MavenJnlp::Icon.should_receive(:find).with("37").and_return(mock_icon)
      mock_icon.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "redirects to the maven_jnlp_icons list" do
      MavenJnlp::Icon.stub!(:find).and_return(mock_icon(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(maven_jnlp_icons_url)
    end

  end

end
