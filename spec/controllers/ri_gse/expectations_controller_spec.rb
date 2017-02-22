require File.expand_path('../../../spec_helper', __FILE__)

describe RiGse::ExpectationsController do

  def mock_expectation(stubs={})
    @mock_expectation ||= mock_model(RiGse::Expectation, stubs)
  end
  
  before(:each) do
    generate_default_settings_and_jnlps_with_mocks
    # generate_portal_resources_with_mocks
    login_admin
  end
  
  describe "responding to GET index" do

    it "should expose an array of all the @expectations" do
      expect(RiGse::Expectation).to receive(:all).and_return([mock_expectation])
      get :index
      expect(assigns[:expectations]).to eq([mock_expectation])
    end

    describe "with mime type of xml" do
  
      it "should render all expectations as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        expect(RiGse::Expectation).to receive(:all).and_return(expectations = double("Array of Expectations"))
        expect(expectations).to receive(:to_xml).and_return("generated XML")
        get :index
        expect(response.body).to eq("generated XML")
      end
    
    end

  end

  describe "responding to GET show" do

    it "should expose the requested expectation as @expectation" do
      expect(RiGse::Expectation).to receive(:find).with("37").and_return(mock_expectation)
      get :show, :id => "37"
      expect(assigns[:expectation]).to equal(mock_expectation)
    end
    
    describe "with mime type of xml" do

      it "should render the requested expectation as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        expect(RiGse::Expectation).to receive(:find).with("37").and_return(mock_expectation)
        expect(mock_expectation).to receive(:to_xml).and_return("generated XML")
        get :show, :id => "37"
        expect(response.body).to eq("generated XML")
      end

    end
    
  end

  describe "responding to GET new" do
  
    it "should expose a new expectation as @expectation" do
      expect(RiGse::Expectation).to receive(:new).and_return(mock_expectation)
      get :new
      expect(assigns[:expectation]).to equal(mock_expectation)
    end

  end

  describe "responding to GET edit" do
  
    it "should expose the requested expectation as @expectation" do
      expect(RiGse::Expectation).to receive(:find).with("37").and_return(mock_expectation)
      get :edit, :id => "37"
      expect(assigns[:expectation]).to equal(mock_expectation)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do
      
      it "should expose a newly created expectation as @expectation" do
        expect(RiGse::Expectation).to receive(:new).with({'these' => 'params'}).and_return(mock_expectation(:save => true))
        post :create, :expectation => {:these => 'params'}
        expect(assigns(:expectation)).to equal(mock_expectation)
      end

      it "should redirect to the created expectation" do
        allow(RiGse::Expectation).to receive(:new).and_return(mock_expectation(:save => true))
        post :create, :expectation => {}
        expect(response).to redirect_to(ri_gse_expectation_url(mock_expectation))
      end
      
    end
    
    describe "with invalid params" do

      it "should expose a newly created but unsaved expectation as @expectation" do
        allow(RiGse::Expectation).to receive(:new).with({'these' => 'params'}).and_return(mock_expectation(:save => false))
        post :create, :expectation => {:these => 'params'}
        expect(assigns(:expectation)).to equal(mock_expectation)
      end

      it "should re-render the 'new' template" do
        allow(RiGse::Expectation).to receive(:new).and_return(mock_expectation(:save => false))
        post :create, :expectation => {}
        expect(response).to render_template('new')
      end
      
    end
    
  end

  describe "responding to PUT udpate" do

    describe "with valid params" do

      it "should update the requested expectation" do
        expect(RiGse::Expectation).to receive(:find).with("37").and_return(mock_expectation)
        expect(mock_expectation).to receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :expectation => {:these => 'params'}
      end

      it "should expose the requested expectation as @expectation" do
        allow(RiGse::Expectation).to receive(:find).and_return(mock_expectation(:update_attributes => true))
        put :update, :id => "1"
        expect(assigns(:expectation)).to equal(mock_expectation)
      end

      it "should redirect to the expectation" do
        allow(RiGse::Expectation).to receive(:find).and_return(mock_expectation(:update_attributes => true))
        put :update, :id => "1"
        expect(response).to redirect_to(ri_gse_expectation_url(mock_expectation))
      end

    end
    
    describe "with invalid params" do

      it "should update the requested expectation" do
        expect(RiGse::Expectation).to receive(:find).with("37").and_return(mock_expectation)
        expect(mock_expectation).to receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :expectation => {:these => 'params'}
      end

      it "should expose the expectation as @expectation" do
        allow(RiGse::Expectation).to receive(:find).and_return(mock_expectation(:update_attributes => false))
        put :update, :id => "1"
        expect(assigns(:expectation)).to equal(mock_expectation)
      end

      it "should re-render the 'edit' template" do
        allow(RiGse::Expectation).to receive(:find).and_return(mock_expectation(:update_attributes => false))
        put :update, :id => "1"
        expect(response).to render_template('edit')
      end

    end

  end

  describe "responding to DELETE destroy" do

    it "should destroy the requested expectation" do
      expect(RiGse::Expectation).to receive(:find).with("37").and_return(mock_expectation)
      expect(mock_expectation).to receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "should redirect to the expectations list" do
      allow(RiGse::Expectation).to receive(:find).and_return(mock_expectation(:destroy => true))
      delete :destroy, :id => "1"
      expect(response).to redirect_to(expectations_url)
    end

  end

end
