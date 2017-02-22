require File.expand_path('../../../spec_helper', __FILE__)

describe RiGse::BigIdeasController do

  def mock_big_idea(stubs={})
    @mock_big_idea ||= mock_model(RiGse::BigIdea, stubs)
  end
  
  before(:each) do
    generate_default_settings_and_jnlps_with_mocks
    # generate_portal_resources_with_mocks
    login_admin
  end
  
  describe "responding to GET index" do

    it "should expose an array of all the @big_ideas" do
      expect(RiGse::BigIdea).to receive(:all).and_return([mock_big_idea])
      get :index
      expect(assigns[:big_ideas]).to eq([mock_big_idea])
    end

    describe "with mime type of xml" do
  
      it "should render all big_ideas as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        expect(RiGse::BigIdea).to receive(:all).and_return(big_ideas = double("Array of BigIdeas"))
        expect(big_ideas).to receive(:to_xml).and_return("generated XML")
        get :index
        expect(response.body).to eq("generated XML")
      end
    
    end

  end

  describe "responding to GET show" do

    it "should expose the requested big_idea as @big_idea" do
      expect(RiGse::BigIdea).to receive(:find).with("37").and_return(mock_big_idea)
      get :show, :id => "37"
      expect(assigns[:big_idea]).to equal(mock_big_idea)
    end
    
    describe "with mime type of xml" do

      it "should render the requested big_idea as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        expect(RiGse::BigIdea).to receive(:find).with("37").and_return(mock_big_idea)
        expect(mock_big_idea).to receive(:to_xml).and_return("generated XML")
        get :show, :id => "37"
        expect(response.body).to eq("generated XML")
      end

    end
    
  end

  describe "responding to GET new" do
  
    it "should expose a new big_idea as @big_idea" do
      expect(RiGse::BigIdea).to receive(:new).and_return(mock_big_idea)
      get :new
      expect(assigns[:big_idea]).to equal(mock_big_idea)
    end

  end

  describe "responding to GET edit" do
  
    it "should expose the requested big_idea as @big_idea" do
      expect(RiGse::BigIdea).to receive(:find).with("37").and_return(mock_big_idea)
      get :edit, :id => "37"
      expect(assigns[:big_idea]).to equal(mock_big_idea)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do
      
      it "should expose a newly created big_idea as @big_idea" do
        expect(RiGse::BigIdea).to receive(:new).with({'these' => 'params'}).and_return(mock_big_idea(:save => true))
        post :create, :big_idea => {:these => 'params'}
        expect(assigns(:big_idea)).to equal(mock_big_idea)
      end

      it "should redirect to the created big_idea" do
        allow(RiGse::BigIdea).to receive(:new).and_return(mock_big_idea(:save => true))
        post :create, :big_idea => {}
        expect(response).to redirect_to(ri_gse_big_idea_url(mock_big_idea))
      end
      
    end
    
    describe "with invalid params" do

      it "should expose a newly created but unsaved big_idea as @big_idea" do
        allow(RiGse::BigIdea).to receive(:new).with({'these' => 'params'}).and_return(mock_big_idea(:save => false))
        post :create, :big_idea => {:these => 'params'}
        expect(assigns(:big_idea)).to equal(mock_big_idea)
      end

      it "should re-render the 'new' template" do
        allow(RiGse::BigIdea).to receive(:new).and_return(mock_big_idea(:save => false))
        post :create, :big_idea => {}
        expect(response).to render_template('new')
      end
      
    end
    
  end

  describe "responding to PUT udpate" do

    describe "with valid params" do

      it "should update the requested big_idea" do
        expect(RiGse::BigIdea).to receive(:find).with("37").and_return(mock_big_idea)
        expect(mock_big_idea).to receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :big_idea => {:these => 'params'}
      end

      it "should expose the requested big_idea as @big_idea" do
        allow(RiGse::BigIdea).to receive(:find).and_return(mock_big_idea(:update_attributes => true))
        put :update, :id => "1"
        expect(assigns(:big_idea)).to equal(mock_big_idea)
      end

      it "should redirect to the big_idea" do
        allow(RiGse::BigIdea).to receive(:find).and_return(mock_big_idea(:update_attributes => true))
        put :update, :id => "1"
        expect(response).to redirect_to(ri_gse_big_idea_url(mock_big_idea))
      end

    end
    
    describe "with invalid params" do

      it "should update the requested big_idea" do
        expect(RiGse::BigIdea).to receive(:find).with("37").and_return(mock_big_idea)
        expect(mock_big_idea).to receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :big_idea => {:these => 'params'}
      end

      it "should expose the big_idea as @big_idea" do
        allow(RiGse::BigIdea).to receive(:find).and_return(mock_big_idea(:update_attributes => false))
        put :update, :id => "1"
        expect(assigns(:big_idea)).to equal(mock_big_idea)
      end

      it "should re-render the 'edit' template" do
        allow(RiGse::BigIdea).to receive(:find).and_return(mock_big_idea(:update_attributes => false))
        put :update, :id => "1"
        expect(response).to render_template('edit')
      end

    end

  end

  describe "responding to DELETE destroy" do

    it "should destroy the requested big_idea" do
      expect(RiGse::BigIdea).to receive(:find).with("37").and_return(mock_big_idea)
      expect(mock_big_idea).to receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "should redirect to the big_ideas list" do
      allow(RiGse::BigIdea).to receive(:find).and_return(mock_big_idea(:destroy => true))
      delete :destroy, :id => "1"
      expect(response).to redirect_to(big_ideas_url)
    end

  end

end
