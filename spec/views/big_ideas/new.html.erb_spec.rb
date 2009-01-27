require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/big_ideas/new.html.erb" do
  include BigIdeasHelper
  
  before(:each) do
    assigns[:big_idea] = stub_model(BigIdea,
      :new_record? => true
    )
  end

  it "should render new form" do
    render "/big_ideas/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", big_ideas_path) do
    end
  end
end


