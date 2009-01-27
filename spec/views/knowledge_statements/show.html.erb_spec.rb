require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/knowledge_statements/show.html.erb" do
  include KnowledgeStatementsHelper
  
  before(:each) do
    assigns[:knowledge_statement] = @knowledge_statement = stub_model(KnowledgeStatement)
  end

  it "should render attributes in <p>" do
    render "/knowledge_statements/show.html.erb"
  end
end

