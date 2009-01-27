require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/domains/edit.html.erb" do
  include DomainsHelper
  
  before(:each) do
    assigns[:domain] = @domain = stub_model(Domain,
      :new_record? => false
    )
  end

  it "should render edit form" do
    render "/domains/edit.html.erb"
    
    response.should have_tag("form[action=#{domain_path(@domain)}][method=post]") do
    end
  end
end


