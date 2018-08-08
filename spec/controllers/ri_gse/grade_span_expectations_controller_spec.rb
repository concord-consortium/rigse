require File.expand_path('../../../spec_helper', __FILE__)

describe RiGse::GradeSpanExpectationsController do

  def mock_grade_span_expectation(stubs={})
    @mock_grade_span_expectation ||= mock_model(RiGse::GradeSpanExpectation, stubs)
  end
  
  before(:each) do
    generate_default_settings_and_jnlps_with_mocks
    # generate_portal_resources_with_mocks
    login_admin
  end

  describe "responding to GET index" do

    it "should expose a paginated array of @grade_span_expectations" do
      expect(RiGse::GradeSpanExpectation).to receive(:search).and_return([mock_grade_span_expectation])
      get :index
      expect(assigns[:grade_span_expectations]).to eq([mock_grade_span_expectation])
    end

    describe "with mime type of xml" do
  
      it "should render all grade_span_expectations as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        expect(RiGse::GradeSpanExpectation).to receive(:all).and_return(grade_span_expectations = double("Array of GradeSpanExpectations"))
        expect(grade_span_expectations).to receive(:to_xml).and_return("generated XML")
        get :index
        expect(response.body).to eq("generated XML")
      end
    
    end

  end

  describe "responding to GET show" do

    it "should expose the requested grade_span_expectation as @grade_span_expectation" do
      expect(RiGse::GradeSpanExpectation).to receive(:find).with("37").and_return(mock_grade_span_expectation)
      get :show, :id => "37"
      expect(assigns[:grade_span_expectation]).to equal(mock_grade_span_expectation)
    end
    
    describe "with mime type of xml" do

      it "should render the requested grade_span_expectation as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        expect(RiGse::GradeSpanExpectation).to receive(:find).with("37").and_return(mock_grade_span_expectation)
        expect(mock_grade_span_expectation).to receive(:to_xml).and_return("generated XML")
        get :show, :id => "37"
        expect(response.body).to eq("generated XML")
      end

    end
    
  end

  describe "responding to GET new" do
  
    it "should expose a new grade_span_expectation as @grade_span_expectation" do
      expect(RiGse::GradeSpanExpectation).to receive(:new).and_return(mock_grade_span_expectation)
      get :new
      expect(assigns[:grade_span_expectation]).to equal(mock_grade_span_expectation)
    end

  end

  describe "responding to GET edit" do
  
    it "should expose the requested grade_span_expectation as @grade_span_expectation" do
      expect(RiGse::GradeSpanExpectation).to receive(:find).with("37").and_return(mock_grade_span_expectation)
      get :edit, :id => "37"
      expect(assigns[:grade_span_expectation]).to equal(mock_grade_span_expectation)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do
      
      it "should expose a newly created grade_span_expectation as @grade_span_expectation" do
        expect(RiGse::GradeSpanExpectation).to receive(:new).with({'these' => 'params'}).and_return(mock_grade_span_expectation(:save => true))
        post :create, :grade_span_expectation => {:these => 'params'}
        expect(assigns(:grade_span_expectation)).to equal(mock_grade_span_expectation)
      end

      it "should redirect to the created grade_span_expectation" do
        allow(RiGse::GradeSpanExpectation).to receive(:new).and_return(mock_grade_span_expectation(:save => true))
        post :create, :grade_span_expectation => {}
        expect(response).to redirect_to(ri_gse_grade_span_expectation_url(mock_grade_span_expectation))
      end
      
    end
    
    describe "with invalid params" do

      it "should expose a newly created but unsaved grade_span_expectation as @grade_span_expectation" do
        allow(RiGse::GradeSpanExpectation).to receive(:new).with({'these' => 'params'}).and_return(mock_grade_span_expectation(:save => false))
        post :create, :grade_span_expectation => {:these => 'params'}
        expect(assigns(:grade_span_expectation)).to equal(mock_grade_span_expectation)
      end

      it "should re-render the 'new' template" do
        allow(RiGse::GradeSpanExpectation).to receive(:new).and_return(mock_grade_span_expectation(:save => false))
        post :create, :grade_span_expectation => {}
        expect(response).to render_template('new')
      end
      
    end
    
  end

  describe "responding to PUT udpate" do

    describe "with valid params" do

      it "should update the requested grade_span_expectation" do
        expect(RiGse::GradeSpanExpectation).to receive(:find).with("37").and_return(mock_grade_span_expectation)
        expect(mock_grade_span_expectation).to receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :grade_span_expectation => {:these => 'params'}
      end

      it "should expose the requested grade_span_expectation as @grade_span_expectation" do
        allow(RiGse::GradeSpanExpectation).to receive(:find).and_return(mock_grade_span_expectation(:update_attributes => true))
        put :update, :id => "1"
        expect(assigns(:grade_span_expectation)).to equal(mock_grade_span_expectation)
      end

      it "should redirect to the grade_span_expectation" do
        allow(RiGse::GradeSpanExpectation).to receive(:find).and_return(mock_grade_span_expectation(:update_attributes => true))
        put :update, :id => "1"
        expect(response).to redirect_to(ri_gse_grade_span_expectation_url(mock_grade_span_expectation))
      end

    end
    
    describe "with invalid params" do

      it "should update the requested grade_span_expectation" do
        expect(RiGse::GradeSpanExpectation).to receive(:find).with("37").and_return(mock_grade_span_expectation)
        expect(mock_grade_span_expectation).to receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :grade_span_expectation => {:these => 'params'}
      end

      it "should expose the grade_span_expectation as @grade_span_expectation" do
        allow(RiGse::GradeSpanExpectation).to receive(:find).and_return(mock_grade_span_expectation(:update_attributes => false))
        put :update, :id => "1"
        expect(assigns(:grade_span_expectation)).to equal(mock_grade_span_expectation)
      end

      it "should re-render the 'edit' template" do
        allow(RiGse::GradeSpanExpectation).to receive(:find).and_return(mock_grade_span_expectation(:update_attributes => false))
        put :update, :id => "1"
        expect(response).to render_template('edit')
      end

    end

  end

  describe "responding to DELETE destroy" do

    it "should destroy the requested grade_span_expectation" do
      expect(RiGse::GradeSpanExpectation).to receive(:find).with("37").and_return(mock_grade_span_expectation)
      expect(mock_grade_span_expectation).to receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "should redirect to the grade_span_expectations list" do
      allow(RiGse::GradeSpanExpectation).to receive(:find).and_return(mock_grade_span_expectation(:destroy => true))
      delete :destroy, :id => "1"
      expect(response).to redirect_to(grade_span_expectations_url)
    end

  end

end
