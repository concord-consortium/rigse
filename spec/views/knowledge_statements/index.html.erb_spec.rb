require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/knowledge_statements/index.html.erb" do
  include KnowledgeStatementsHelper
  
  before(:each) do
    assigns[:knowledge_statements] = [
      stub_model(KnowledgeStatement),
      stub_model(KnowledgeStatement)
    ]
  end

  it "should render list of knowledge_statements" do
    render "/knowledge_statements/index.html.erb"
  end
end

