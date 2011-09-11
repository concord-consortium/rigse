require File.expand_path('../../../spec_helper', __FILE__)

describe RiGse::KnowledgeStatementsController do

  def mock_knowledge_statement(stubs={})
    @mock_knowledge_statement ||= mock_model(RiGse::KnowledgeStatement, stubs)
  end
  
  before(:each) do
    generate_default_project_and_jnlps_with_mocks
    # generate_portal_resources_with_mocks
    login_admin
  end
  
  describe "responding to GET index" do

    it "should expose an array of all the @knowledge_statements" do
      RiGse::KnowledgeStatement.should_receive(:all).and_return([mock_knowledge_statement])
      get :index
      assigns[:knowledge_statements].should == [mock_knowledge_statement]
    end

    describe "with mime type of xml" do
  
      it "should render all knowledge_statements as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        RiGse::KnowledgeStatement.should_receive(:all).and_return(knowledge_statements = mock("Array of KnowledgeStatements"))
        knowledge_statements.should_receive(:to_xml).and_return("generated XML")
        get :index
        response.body.should == "generated XML"
      end
    
    end

  end

  describe "responding to GET show" do

    it "should expose the requested knowledge_statement as @knowledge_statement" do
      RiGse::KnowledgeStatement.should_receive(:find).with("37").and_return(mock_knowledge_statement)
      get :show, :id => "37"
      assigns[:knowledge_statement].should equal(mock_knowledge_statement)
    end
    
    describe "with mime type of xml" do

      it "should render the requested knowledge_statement as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        RiGse::KnowledgeStatement.should_receive(:find).with("37").and_return(mock_knowledge_statement)
        mock_knowledge_statement.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37"
        response.body.should == "generated XML"
      end

    end
    
  end

  describe "responding to GET new" do
  
    it "should expose a new knowledge_statement as @knowledge_statement" do
      RiGse::KnowledgeStatement.should_receive(:new).and_return(mock_knowledge_statement)
      get :new
      assigns[:knowledge_statement].should equal(mock_knowledge_statement)
    end

  end

  describe "responding to GET edit" do
  
    it "should expose the requested knowledge_statement as @knowledge_statement" do
      RiGse::KnowledgeStatement.should_receive(:find).with("37").and_return(mock_knowledge_statement)
      get :edit, :id => "37"
      assigns[:knowledge_statement].should equal(mock_knowledge_statement)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do
      
      it "should expose a newly created knowledge_statement as @knowledge_statement" do
        RiGse::KnowledgeStatement.should_receive(:new).with({'these' => 'params'}).and_return(mock_knowledge_statement(:save => true))
        post :create, :knowledge_statement => {:these => 'params'}
        assigns(:knowledge_statement).should equal(mock_knowledge_statement)
      end

      it "should redirect to the created knowledge_statement" do
        RiGse::KnowledgeStatement.stub!(:new).and_return(mock_knowledge_statement(:save => true))
        post :create, :knowledge_statement => {}
        response.should redirect_to(ri_gse_knowledge_statement_url(mock_knowledge_statement))
      end
      
    end
    
    describe "with invalid params" do

      it "should expose a newly created but unsaved knowledge_statement as @knowledge_statement" do
        RiGse::KnowledgeStatement.stub!(:new).with({'these' => 'params'}).and_return(mock_knowledge_statement(:save => false))
        post :create, :knowledge_statement => {:these => 'params'}
        assigns(:knowledge_statement).should equal(mock_knowledge_statement)
      end

      it "should re-render the 'new' template" do
        RiGse::KnowledgeStatement.stub!(:new).and_return(mock_knowledge_statement(:save => false))
        post :create, :knowledge_statement => {}
        response.should render_template('new')
      end
      
    end
    
  end

  describe "responding to PUT udpate" do

    describe "with valid params" do

      it "should update the requested knowledge_statement" do
        RiGse::KnowledgeStatement.should_receive(:find).with("37").and_return(mock_knowledge_statement)
        mock_knowledge_statement.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :knowledge_statement => {:these => 'params'}
      end

      it "should expose the requested knowledge_statement as @knowledge_statement" do
        RiGse::KnowledgeStatement.stub!(:find).and_return(mock_knowledge_statement(:update_attributes => true))
        put :update, :id => "1"
        assigns(:knowledge_statement).should equal(mock_knowledge_statement)
      end

      it "should redirect to the knowledge_statement" do
        RiGse::KnowledgeStatement.stub!(:find).and_return(mock_knowledge_statement(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(ri_gse_knowledge_statement_url(mock_knowledge_statement))
      end

    end
    
    describe "with invalid params" do

      it "should update the requested knowledge_statement" do
        RiGse::KnowledgeStatement.should_receive(:find).with("37").and_return(mock_knowledge_statement)
        mock_knowledge_statement.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :knowledge_statement => {:these => 'params'}
      end

      it "should expose the knowledge_statement as @knowledge_statement" do
        RiGse::KnowledgeStatement.stub!(:find).and_return(mock_knowledge_statement(:update_attributes => false))
        put :update, :id => "1"
        assigns(:knowledge_statement).should equal(mock_knowledge_statement)
      end

      it "should re-render the 'edit' template" do
        RiGse::KnowledgeStatement.stub!(:find).and_return(mock_knowledge_statement(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "responding to DELETE destroy" do

    it "should destroy the requested knowledge_statement" do
      RiGse::KnowledgeStatement.should_receive(:find).with("37").and_return(mock_knowledge_statement)
      mock_knowledge_statement.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "should redirect to the knowledge_statements list" do
      RiGse::KnowledgeStatement.stub!(:find).and_return(mock_knowledge_statement(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(knowledge_statements_url)
    end

  end

end
