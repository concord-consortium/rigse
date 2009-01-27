require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/big_ideas/index.html.erb" do
  include BigIdeasHelper
  
  before(:each) do
    assigns[:big_ideas] = [
      stub_model(BigIdea),
      stub_model(BigIdea)
    ]
  end

  it "should render list of big_ideas" do
    render "/big_ideas/index.html.erb"
  end
end

