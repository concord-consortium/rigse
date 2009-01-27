require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/big_ideas/show.html.erb" do
  include BigIdeasHelper
  
  before(:each) do
    assigns[:big_idea] = @big_idea = stub_model(BigIdea)
  end

  it "should render attributes in <p>" do
    render "/big_ideas/show.html.erb"
  end
end

