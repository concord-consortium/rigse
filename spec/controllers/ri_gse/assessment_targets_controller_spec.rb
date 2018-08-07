require File.expand_path('../../../spec_helper', __FILE__)

describe RiGse::AssessmentTargetsController do

  def mock_assessment_target(stubs={})
    @mock_assessment_target ||= mock_model(RiGse::AssessmentTarget, stubs)
  end

  before(:each) do
    generate_default_settings_and_jnlps_with_mocks
    # generate_portal_resources_with_mocks
    login_admin
  end
  
  describe "responding to GET index" do

    it "should expose an array of all the @assessment_targets" do
      expect(RiGse::AssessmentTarget).to receive(:search).and_return([mock_assessment_target])
      get :index
      expect(assigns[:assessment_targets]).to eq([mock_assessment_target])
    end

    describe "with mime type of xml" do
  
      it "should render all assessment_targets as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        expect(RiGse::AssessmentTarget).to receive(:all).and_return(assessment_targets = double("Array of AssessmentTargets"))
        expect(assessment_targets).to receive(:to_xml).and_return("generated XML")
        get :index
        expect(response.body).to eq("generated XML")
      end
    
    end

  end

  describe "responding to GET show" do

    it "should expose the requested assessment_target as @assessment_target" do
      expect(RiGse::AssessmentTarget).to receive(:find).with("37").and_return(mock_assessment_target)
      get :show, :id => "37"
      expect(assigns[:assessment_target]).to equal(mock_assessment_target)
    end
    
    describe "with mime type of xml" do

      it "should render the requested assessment_target as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        expect(RiGse::AssessmentTarget).to receive(:find).with("37").and_return(mock_assessment_target)
        expect(mock_assessment_target).to receive(:to_xml).and_return("generated XML")
        get :show, :id => "37"
        expect(response.body).to eq("generated XML")
      end

    end
    
  end

  describe "responding to GET new" do
  
    it "should expose a new assessment_target as @assessment_target" do
      expect(RiGse::AssessmentTarget).to receive(:new).and_return(mock_assessment_target)
      get :new
      expect(assigns[:assessment_target]).to equal(mock_assessment_target)
    end

  end

  describe "responding to GET edit" do
  
    it "should expose the requested assessment_target as @assessment_target" do
      expect(RiGse::AssessmentTarget).to receive(:find).with("37").and_return(mock_assessment_target)
      get :edit, :id => "37"
      expect(assigns[:assessment_target]).to equal(mock_assessment_target)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do
      
      it "should expose a newly created assessment_target as @assessment_target" do
        expect(RiGse::AssessmentTarget).to receive(:new).with({'these' => 'params'}).and_return(mock_assessment_target(:save => true))
        post :create, :assessment_target => {:these => 'params'}
        expect(assigns(:assessment_target)).to equal(mock_assessment_target)
      end

      it "should redirect to the created assessment_target" do
        allow(RiGse::AssessmentTarget).to receive(:new).and_return(mock_assessment_target(:save => true))
        post :create, :assessment_target => {}
        expect(response).to redirect_to(ri_gse_assessment_target_url(mock_assessment_target))
      end
      
    end
    
    describe "with invalid params" do

      it "should expose a newly created but unsaved assessment_target as @assessment_target" do
        allow(RiGse::AssessmentTarget).to receive(:new).with({'these' => 'params'}).and_return(mock_assessment_target(:save => false))
        post :create, :assessment_target => {:these => 'params'}
        expect(assigns(:assessment_target)).to equal(mock_assessment_target)
      end

      it "should re-render the 'new' template" do
        allow(RiGse::AssessmentTarget).to receive(:new).and_return(mock_assessment_target(:save => false))
        post :create, :assessment_target => {}
        expect(response).to render_template('new')
      end
      
    end
    
  end

  describe "responding to PUT udpate" do

    describe "with valid params" do

      it "should update the requested assessment_target" do
        expect(RiGse::AssessmentTarget).to receive(:find).with("37").and_return(mock_assessment_target)
        expect(mock_assessment_target).to receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :assessment_target => {:these => 'params'}
      end

      it "should expose the requested assessment_target as @assessment_target" do
        allow(RiGse::AssessmentTarget).to receive(:find).and_return(mock_assessment_target(:update_attributes => true))
        put :update, :id => "1"
        expect(assigns(:assessment_target)).to equal(mock_assessment_target)
      end

      it "should redirect to the assessment_target" do
        allow(RiGse::AssessmentTarget).to receive(:find).and_return(mock_assessment_target(:update_attributes => true))
        put :update, :id => "1"
        expect(response).to redirect_to(ri_gse_assessment_target_url(mock_assessment_target))
      end

    end
    
    describe "with invalid params" do

      it "should update the requested assessment_target" do
        expect(RiGse::AssessmentTarget).to receive(:find).with("37").and_return(mock_assessment_target)
        expect(mock_assessment_target).to receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :assessment_target => {:these => 'params'}
      end

      it "should expose the assessment_target as @assessment_target" do
        allow(RiGse::AssessmentTarget).to receive(:find).and_return(mock_assessment_target(:update_attributes => false))
        put :update, :id => "1"
        expect(assigns(:assessment_target)).to equal(mock_assessment_target)
      end

      it "should re-render the 'edit' template" do
        allow(RiGse::AssessmentTarget).to receive(:find).and_return(mock_assessment_target(:update_attributes => false))
        put :update, :id => "1"
        expect(response).to render_template('edit')
      end

    end

  end

  describe "responding to DELETE destroy" do

    it "should destroy the requested assessment_target" do
      expect(RiGse::AssessmentTarget).to receive(:find).with("37").and_return(mock_assessment_target)
      expect(mock_assessment_target).to receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "should redirect to the assessment_targets list" do
      allow(RiGse::AssessmentTarget).to receive(:find).and_return(mock_assessment_target(:destroy => true))
      delete :destroy, :id => "1"
      expect(response).to redirect_to(assessment_targets_url)
    end

  end

end
