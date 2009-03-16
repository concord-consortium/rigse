require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/investigations/show.html.erb" do
  include InvestigationsHelper
  
  before(:each) do
    assigns[:investigation] = @investigation = stub_model(Investigation,
      :title => "value for title",
      :context => "value for context",
      :opportunities => "value for opportunities",
      :objectives => "value for objectives",
      :procedures_opening => "value for procedures_opening",
      :procedures_engagement => "value for procedures_engagement",
      :procedures_closure => "value for procedures_closure",
      :assessment => "value for assessment",
      :reflection => "value for reflection"
    )
  end

  it "should render attributes in <p>" do
    render "/investigations/show.html.erb"
    response.should have_text(/value\ for\ title/)
    response.should have_text(/value\ for\ context/)
    response.should have_text(/value\ for\ opportunities/)
    response.should have_text(/value\ for\ objectives/)
    response.should have_text(/value\ for\ procedures_opening/)
    response.should have_text(/value\ for\ procedures_engagement/)
    response.should have_text(/value\ for\ procedures_closure/)
    response.should have_text(/value\ for\ assessment/)
    response.should have_text(/value\ for\ reflection/)
  end
end

