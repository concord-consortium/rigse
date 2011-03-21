require 'spec_helper'

describe RiGse::BigIdeasController do

  def mock_big_idea(stubs={})
    @mock_big_idea ||= mock_model(RiGse::BigIdea, stubs)
  end
  
  before(:each) do
    generate_default_project_and_jnlps_with_mocks
    # generate_portal_resources_with_mocks
    login_admin
  end
  
  describe "responding to GET index" do

    it "should expose an array of all the @big_ideas" do
      RiGse::BigIdea.should_receive(:find).with(:all).and_return([mock_big_idea])
      get :index
      assigns[:big_ideas].should == [mock_big_idea]
    end

    describe "with mime type of xml" do
  
      it "should render all big_ideas as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        RiGse::BigIdea.should_receive(:find).with(:all).and_return(big_ideas = mock("Array of BigIdeas"))
        big_ideas.should_receive(:to_xml).and_return("generated XML")
        get :index
        response.body.should == "generated XML"
      end
    
    end

  end

  describe "responding to GET show" do

    it "should expose the requested big_idea as @big_idea" do
      RiGse::BigIdea.should_receive(:find).with("37").and_return(mock_big_idea)
      get :show, :id => "37"
      assigns[:big_idea].should equal(mock_big_idea)
    end
    
    describe "with mime type of xml" do

      it "should render the requested big_idea as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        RiGse::BigIdea.should_receive(:find).with("37").and_return(mock_big_idea)
        mock_big_idea.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37"
        response.body.should == "generated XML"
      end

    end
    
  end

  describe "responding to GET new" do
  
    it "should expose a new big_idea as @big_idea" do
      RiGse::BigIdea.should_receive(:new).and_return(mock_big_idea)
      get :new
      assigns[:big_idea].should equal(mock_big_idea)
    end

  end

  describe "responding to GET edit" do
  
    it "should expose the requested big_idea as @big_idea" do
      RiGse::BigIdea.should_receive(:find).with("37").and_return(mock_big_idea)
      get :edit, :id => "37"
      assigns[:big_idea].should equal(mock_big_idea)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do
      
      it "should expose a newly created big_idea as @big_idea" do
        RiGse::BigIdea.should_receive(:new).with({'these' => 'params'}).and_return(mock_big_idea(:save => true))
        post :create, :big_idea => {:these => 'params'}
        assigns(:big_idea).should equal(mock_big_idea)
      end

      it "should redirect to the created big_idea" do
        RiGse::BigIdea.stub!(:new).and_return(mock_big_idea(:save => true))
        post :create, :big_idea => {}
        response.should redirect_to(ri_gse_big_idea_url(mock_big_idea))
      end
      
    end
    
    describe "with invalid params" do

      it "should expose a newly created but unsaved big_idea as @big_idea" do
        RiGse::BigIdea.stub!(:new).with({'these' => 'params'}).and_return(mock_big_idea(:save => false))
        post :create, :big_idea => {:these => 'params'}
        assigns(:big_idea).should equal(mock_big_idea)
      end

      it "should re-render the 'new' template" do
        RiGse::BigIdea.stub!(:new).and_return(mock_big_idea(:save => false))
        post :create, :big_idea => {}
        response.should render_template('new')
      end
      
    end
    
  end

  describe "responding to PUT udpate" do

    describe "with valid params" do

      it "should update the requested big_idea" do
        RiGse::BigIdea.should_receive(:find).with("37").and_return(mock_big_idea)
        mock_big_idea.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :big_idea => {:these => 'params'}
      end

      it "should expose the requested big_idea as @big_idea" do
        RiGse::BigIdea.stub!(:find).and_return(mock_big_idea(:update_attributes => true))
        put :update, :id => "1"
        assigns(:big_idea).should equal(mock_big_idea)
      end

      it "should redirect to the big_idea" do
        RiGse::BigIdea.stub!(:find).and_return(mock_big_idea(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(ri_gse_big_idea_url(mock_big_idea))
      end

    end
    
    describe "with invalid params" do

      it "should update the requested big_idea" do
        RiGse::BigIdea.should_receive(:find).with("37").and_return(mock_big_idea)
        mock_big_idea.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :big_idea => {:these => 'params'}
      end

      it "should expose the big_idea as @big_idea" do
        RiGse::BigIdea.stub!(:find).and_return(mock_big_idea(:update_attributes => false))
        put :update, :id => "1"
        assigns(:big_idea).should equal(mock_big_idea)
      end

      it "should re-render the 'edit' template" do
        RiGse::BigIdea.stub!(:find).and_return(mock_big_idea(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "responding to DELETE destroy" do

    it "should destroy the requested big_idea" do
      RiGse::BigIdea.should_receive(:find).with("37").and_return(mock_big_idea)
      mock_big_idea.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "should redirect to the big_ideas list" do
      RiGse::BigIdea.stub!(:find).and_return(mock_big_idea(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(big_ideas_url)
    end

  end

end
