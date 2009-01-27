require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/big_ideas/edit.html.erb" do
  include BigIdeasHelper
  
  before(:each) do
    assigns[:big_idea] = @big_idea = stub_model(BigIdea,
      :new_record? => false
    )
  end

  it "should render edit form" do
    render "/big_ideas/edit.html.erb"
    
    response.should have_tag("form[action=#{big_idea_path(@big_idea)}][method=post]") do
    end
  end
end


