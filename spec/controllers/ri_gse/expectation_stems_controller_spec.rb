require 'spec_helper'

describe RiGse::ExpectationStemsController do

  def mock_expectation_stem(stubs={})
    @mock_expectation_stem ||= mock_model(RiGse::ExpectationStem, stubs)
  end
  
  before(:each) do
    generate_default_project_and_jnlps_with_mocks
    # generate_portal_resources_with_mocks
    login_admin
  end
  
  describe "responding to GET index" do

    it "should expose an array of all the @expectation_stems" do
      RiGse::ExpectationStem.should_receive(:find).with(:all).and_return([mock_expectation_stem])
      get :index
      assigns[:expectation_stems].should == [mock_expectation_stem]
    end

    describe "with mime type of xml" do
  
      it "should render all expectation_stems as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        RiGse::ExpectationStem.should_receive(:find).with(:all).and_return(expectation_stems = mock("Array of ExpectationStems"))
        expectation_stems.should_receive(:to_xml).and_return("generated XML")
        get :index
        response.body.should == "generated XML"
      end
    
    end

  end

  describe "responding to GET show" do

    it "should expose the requested expectation_stem as @expectation_stem" do
      RiGse::ExpectationStem.should_receive(:find).with("37").and_return(mock_expectation_stem)
      get :show, :id => "37"
      assigns[:expectation_stem].should equal(mock_expectation_stem)
    end
    
    describe "with mime type of xml" do

      it "should render the requested expectation_stem as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        RiGse::ExpectationStem.should_receive(:find).with("37").and_return(mock_expectation_stem)
        mock_expectation_stem.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37"
        response.body.should == "generated XML"
      end

    end
    
  end

  describe "responding to GET new" do
  
    it "should expose a new expectation_stem as @expectation_stem" do
      RiGse::ExpectationStem.should_receive(:new).and_return(mock_expectation_stem)
      get :new
      assigns[:expectation_stem].should equal(mock_expectation_stem)
    end

  end

  describe "responding to GET edit" do
  
    it "should expose the requested expectation_stem as @expectation_stem" do
      RiGse::ExpectationStem.should_receive(:find).with("37").and_return(mock_expectation_stem)
      get :edit, :id => "37"
      assigns[:expectation_stem].should equal(mock_expectation_stem)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do
      
      it "should expose a newly created expectation_stem as @expectation_stem" do
        RiGse::ExpectationStem.should_receive(:new).with({'these' => 'params'}).and_return(mock_expectation_stem(:save => true))
        post :create, :expectation_stem => {:these => 'params'}
        assigns(:expectation_stem).should equal(mock_expectation_stem)
      end

      it "should redirect to the created expectation_stem" do
        RiGse::ExpectationStem.stub!(:new).and_return(mock_expectation_stem(:save => true))
        post :create, :expectation_stem => {}
        response.should redirect_to(ri_gse_expectation_stem_url(mock_expectation_stem))
      end
      
    end
    
    describe "with invalid params" do

      it "should expose a newly created but unsaved expectation_stem as @expectation_stem" do
        RiGse::ExpectationStem.stub!(:new).with({'these' => 'params'}).and_return(mock_expectation_stem(:save => false))
        post :create, :expectation_stem => {:these => 'params'}
        assigns(:expectation_stem).should equal(mock_expectation_stem)
      end

      it "should re-render the 'new' template" do
        RiGse::ExpectationStem.stub!(:new).and_return(mock_expectation_stem(:save => false))
        post :create, :expectation_stem => {}
        response.should render_template('new')
      end
      
    end
    
  end

  describe "responding to PUT udpate" do

    describe "with valid params" do

      it "should update the requested expectation_stem" do
        RiGse::ExpectationStem.should_receive(:find).with("37").and_return(mock_expectation_stem)
        mock_expectation_stem.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :expectation_stem => {:these => 'params'}
      end

      it "should expose the requested expectation_stem as @expectation_stem" do
        RiGse::ExpectationStem.stub!(:find).and_return(mock_expectation_stem(:update_attributes => true))
        put :update, :id => "1"
        assigns(:expectation_stem).should equal(mock_expectation_stem)
      end

      it "should redirect to the expectation_stem" do
        RiGse::ExpectationStem.stub!(:find).and_return(mock_expectation_stem(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(ri_gse_expectation_stem_url(mock_expectation_stem))
      end

    end
    
    describe "with invalid params" do

      it "should update the requested expectation_stem" do
        RiGse::ExpectationStem.should_receive(:find).with("37").and_return(mock_expectation_stem)
        mock_expectation_stem.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :expectation_stem => {:these => 'params'}
      end

      it "should expose the expectation_stem as @expectation_stem" do
        RiGse::ExpectationStem.stub!(:find).and_return(mock_expectation_stem(:update_attributes => false))
        put :update, :id => "1"
        assigns(:expectation_stem).should equal(mock_expectation_stem)
      end

      it "should re-render the 'edit' template" do
        RiGse::ExpectationStem.stub!(:find).and_return(mock_expectation_stem(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "responding to DELETE destroy" do

    it "should destroy the requested expectation_stem" do
      RiGse::ExpectationStem.should_receive(:find).with("37").and_return(mock_expectation_stem)
      mock_expectation_stem.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "should redirect to the expectation_stems list" do
      RiGse::ExpectationStem.stub!(:find).and_return(mock_expectation_stem(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(expectation_stems_url)
    end

  end

end
