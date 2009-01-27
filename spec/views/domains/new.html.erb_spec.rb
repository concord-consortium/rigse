require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/domains/new.html.erb" do
  include DomainsHelper
  
  before(:each) do
    assigns[:domain] = stub_model(Domain,
      :new_record? => true
    )
  end

  it "should render new form" do
    render "/domains/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", domains_path) do
    end
  end
end


