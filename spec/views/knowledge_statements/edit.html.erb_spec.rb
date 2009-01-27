require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/knowledge_statements/edit.html.erb" do
  include KnowledgeStatementsHelper
  
  before(:each) do
    assigns[:knowledge_statement] = @knowledge_statement = stub_model(KnowledgeStatement,
      :new_record? => false
    )
  end

  it "should render edit form" do
    render "/knowledge_statements/edit.html.erb"
    
    response.should have_tag("form[action=#{knowledge_statement_path(@knowledge_statement)}][method=post]") do
    end
  end
end


