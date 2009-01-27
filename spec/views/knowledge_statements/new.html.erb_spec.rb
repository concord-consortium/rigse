require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/knowledge_statements/new.html.erb" do
  include KnowledgeStatementsHelper
  
  before(:each) do
    assigns[:knowledge_statement] = stub_model(KnowledgeStatement,
      :new_record? => true
    )
  end

  it "should render new form" do
    render "/knowledge_statements/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", knowledge_statements_path) do
    end
  end
end


