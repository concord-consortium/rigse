require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/expectations/new.html.erb" do
  include ExpectationsHelper
  
  before(:each) do
    assigns[:expectation] = stub_model(Expectation,
      :new_record? => true
    )
  end

  it "should render new form" do
    render "/expectations/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", expectations_path) do
    end
  end
end


