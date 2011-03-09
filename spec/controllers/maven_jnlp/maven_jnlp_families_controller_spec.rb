require 'spec_helper'

describe MavenJnlp::MavenJnlpFamiliesController do

  def mock_maven_jnlp_family(stubs={})
    @maven_jnlp_family.stub!(stubs) unless stubs.empty?
    @maven_jnlp_family
  end

  before(:each) do
    generate_default_project_and_jnlps_with_factories
    logout_user
  end

  describe "GET index" do

    it "exposes all maven_jnlp_maven_jnlp_families as @maven_jnlp_maven_jnlp_families" do
      MavenJnlp::MavenJnlpFamily.should_receive(:find).with(:all).and_return([@maven_jnlp_family])
      get :index
      assigns[:maven_jnlp_maven_jnlp_families].should == [@maven_jnlp_family]
    end

    describe "with mime type of xml" do

      it "renders all maven_jnlp_maven_jnlp_families as xml" do
        MavenJnlp::MavenJnlpFamily.should_receive(:find).with(:all).and_return(maven_jnlp_families = mock("Array of MavenJnlp::MavenJnlpFamilies"))
        maven_jnlp_families.should_receive(:to_xml).and_return("generated XML")
        get :index, :format => 'xml'
        response.body.should == "generated XML"
      end

    end

  end

  describe "GET show" do

    it "exposes the requested maven_jnlp_family as @maven_jnlp_family" do
      MavenJnlp::MavenJnlpFamily.should_receive(:find).with("37").and_return(@maven_jnlp_family)
      get :show, :id => "37"
      assigns[:maven_jnlp_family].should equal(@maven_jnlp_family)
    end

    describe "with mime type of xml" do

      it "renders the requested maven_jnlp_family as xml" do
        MavenJnlp::MavenJnlpFamily.should_receive(:find).with("37").and_return(@maven_jnlp_family)
        @maven_jnlp_family.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37", :format => 'xml'
        response.body.should == "generated XML"
      end

    end

  end

  describe "GET new" do

    it "exposes a new maven_jnlp_family as @maven_jnlp_family" do
      MavenJnlp::MavenJnlpFamily.should_receive(:new).and_return(@maven_jnlp_family)
      get :new
      assigns[:maven_jnlp_family].should equal(@maven_jnlp_family)
    end

  end

  describe "GET edit" do

    it "exposes the requested maven_jnlp_family as @maven_jnlp_family" do
      MavenJnlp::MavenJnlpFamily.should_receive(:find).with("37").and_return(@maven_jnlp_family)
      get :edit, :id => "37"
      assigns[:maven_jnlp_family].should equal(@maven_jnlp_family)
    end

  end

  describe "POST create" do

    describe "with valid params" do

      it "exposes a newly created maven_jnlp_family as @maven_jnlp_family" do
        MavenJnlp::MavenJnlpFamily.should_receive(:new).with({'these' => 'params'}).and_return(mock_maven_jnlp_family(:save => true))
        post :create, :maven_jnlp_family => {:these => 'params'}
        assigns(:maven_jnlp_family).should equal(@maven_jnlp_family)
      end

      it "redirects to the created maven_jnlp_family" do
        MavenJnlp::MavenJnlpFamily.should_receive(:new).and_return(mock_maven_jnlp_family(:save => true))
        post :create, :maven_jnlp_family => {}
        response.should redirect_to(maven_jnlp_maven_jnlp_family_url(@maven_jnlp_family))
      end

    end

    describe "with invalid params" do

      it "exposes a newly created but unsaved maven_jnlp_family as @maven_jnlp_family" do
        MavenJnlp::MavenJnlpFamily.should_receive(:new).with({'these' => 'params'}).and_return(mock_maven_jnlp_family(:save => false))
        post :create, :maven_jnlp_family => {:these => 'params'}
        assigns(:maven_jnlp_family).should equal(@maven_jnlp_family)
      end

      it "re-renders the 'new' template" do
        MavenJnlp::MavenJnlpFamily.should_receive(:new).and_return(mock_maven_jnlp_family(:save => false))
        post :create, :maven_jnlp_family => {}
        response.should render_template('new')
      end

    end

  end

  describe "PUT udpate" do

    describe "with valid params" do

      it "updates the requested maven_jnlp_family" do
        MavenJnlp::MavenJnlpFamily.should_receive(:find).with("37").and_return(@maven_jnlp_family)
        @maven_jnlp_family.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :maven_jnlp_family => {:these => 'params'}
      end

      it "exposes the requested maven_jnlp_family as @maven_jnlp_family" do
        MavenJnlp::MavenJnlpFamily.should_receive(:find).and_return(mock_maven_jnlp_family(:update_attributes => true))
        put :update, :id => "1"
        assigns(:maven_jnlp_family).should equal(@maven_jnlp_family)
      end

      it "redirects to the maven_jnlp_family" do
        MavenJnlp::MavenJnlpFamily.should_receive(:find).and_return(mock_maven_jnlp_family(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(maven_jnlp_maven_jnlp_family_url(@maven_jnlp_family))
      end

    end

    describe "with invalid params" do

      it "updates the requested maven_jnlp_family" do
        MavenJnlp::MavenJnlpFamily.should_receive(:find).with("37").and_return(@maven_jnlp_family)
        @maven_jnlp_family.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :maven_jnlp_family => {:these => 'params'}
      end

      it "exposes the maven_jnlp_family as @maven_jnlp_family" do
        MavenJnlp::MavenJnlpFamily.should_receive(:find).and_return(mock_maven_jnlp_family(:update_attributes => false))
        put :update, :id => "1"
        assigns(:maven_jnlp_family).should equal(@maven_jnlp_family)
      end

      it "re-renders the 'edit' template" do
        MavenJnlp::MavenJnlpFamily.should_receive(:find).and_return(mock_maven_jnlp_family(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "DELETE destroy" do

    it "destroys the requested maven_jnlp_family" do
      MavenJnlp::MavenJnlpFamily.should_receive(:find).with("37").and_return(@maven_jnlp_family)
      @maven_jnlp_family.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the maven_jnlp_maven_jnlp_families list" do
      MavenJnlp::MavenJnlpFamily.should_receive(:find).and_return(mock_maven_jnlp_family(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(maven_jnlp_maven_jnlp_families_url)
    end
  end
end
