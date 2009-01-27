require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ExpectationsController do

  def mock_expectation(stubs={})
    @mock_expectation ||= mock_model(Expectation, stubs)
  end
  
  describe "responding to GET index" do

    it "should expose all expectations as @expectations" do
      Expectation.should_receive(:find).with(:all).and_return([mock_expectation])
      get :index
      assigns[:expectations].should == [mock_expectation]
    end

    describe "with mime type of xml" do
  
      it "should render all expectations as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        Expectation.should_receive(:find).with(:all).and_return(expectations = mock("Array of Expectations"))
        expectations.should_receive(:to_xml).and_return("generated XML")
        get :index
        response.body.should == "generated XML"
      end
    
    end

  end

  describe "responding to GET show" do

    it "should expose the requested expectation as @expectation" do
      Expectation.should_receive(:find).with("37").and_return(mock_expectation)
      get :show, :id => "37"
      assigns[:expectation].should equal(mock_expectation)
    end
    
    describe "with mime type of xml" do

      it "should render the requested expectation as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        Expectation.should_receive(:find).with("37").and_return(mock_expectation)
        mock_expectation.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37"
        response.body.should == "generated XML"
      end

    end
    
  end

  describe "responding to GET new" do
  
    it "should expose a new expectation as @expectation" do
      Expectation.should_receive(:new).and_return(mock_expectation)
      get :new
      assigns[:expectation].should equal(mock_expectation)
    end

  end

  describe "responding to GET edit" do
  
    it "should expose the requested expectation as @expectation" do
      Expectation.should_receive(:find).with("37").and_return(mock_expectation)
      get :edit, :id => "37"
      assigns[:expectation].should equal(mock_expectation)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do
      
      it "should expose a newly created expectation as @expectation" do
        Expectation.should_receive(:new).with({'these' => 'params'}).and_return(mock_expectation(:save => true))
        post :create, :expectation => {:these => 'params'}
        assigns(:expectation).should equal(mock_expectation)
      end

      it "should redirect to the created expectation" do
        Expectation.stub!(:new).and_return(mock_expectation(:save => true))
        post :create, :expectation => {}
        response.should redirect_to(expectation_url(mock_expectation))
      end
      
    end
    
    describe "with invalid params" do

      it "should expose a newly created but unsaved expectation as @expectation" do
        Expectation.stub!(:new).with({'these' => 'params'}).and_return(mock_expectation(:save => false))
        post :create, :expectation => {:these => 'params'}
        assigns(:expectation).should equal(mock_expectation)
      end

      it "should re-render the 'new' template" do
        Expectation.stub!(:new).and_return(mock_expectation(:save => false))
        post :create, :expectation => {}
        response.should render_template('new')
      end
      
    end
    
  end

  describe "responding to PUT udpate" do

    describe "with valid params" do

      it "should update the requested expectation" do
        Expectation.should_receive(:find).with("37").and_return(mock_expectation)
        mock_expectation.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :expectation => {:these => 'params'}
      end

      it "should expose the requested expectation as @expectation" do
        Expectation.stub!(:find).and_return(mock_expectation(:update_attributes => true))
        put :update, :id => "1"
        assigns(:expectation).should equal(mock_expectation)
      end

      it "should redirect to the expectation" do
        Expectation.stub!(:find).and_return(mock_expectation(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(expectation_url(mock_expectation))
      end

    end
    
    describe "with invalid params" do

      it "should update the requested expectation" do
        Expectation.should_receive(:find).with("37").and_return(mock_expectation)
        mock_expectation.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :expectation => {:these => 'params'}
      end

      it "should expose the expectation as @expectation" do
        Expectation.stub!(:find).and_return(mock_expectation(:update_attributes => false))
        put :update, :id => "1"
        assigns(:expectation).should equal(mock_expectation)
      end

      it "should re-render the 'edit' template" do
        Expectation.stub!(:find).and_return(mock_expectation(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "responding to DELETE destroy" do

    it "should destroy the requested expectation" do
      Expectation.should_receive(:find).with("37").and_return(mock_expectation)
      mock_expectation.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "should redirect to the expectations list" do
      Expectation.stub!(:find).and_return(mock_expectation(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(expectations_url)
    end

  end

end
