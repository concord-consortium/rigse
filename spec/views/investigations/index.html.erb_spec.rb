require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/investigations/index.html.erb" do
  include InvestigationsHelper
  
  before(:each) do
    assigns[:investigations] = [
      stub_model(Investigation,
        :title => "value for title",
        :context => "value for context",
        :opportunities => "value for opportunities",
        :objectives => "value for objectives",
        :procedures_opening => "value for procedures_opening",
        :procedures_engagement => "value for procedures_engagement",
        :procedures_closure => "value for procedures_closure",
        :assessment => "value for assessment",
        :reflection => "value for reflection"
      ),
      stub_model(Investigation,
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
    ]
  end

  it "should render list of investigations" do
    render "/investigations/index.html.erb"
    response.should have_tag("tr>td", "value for title", 2)
    response.should have_tag("tr>td", "value for context", 2)
    response.should have_tag("tr>td", "value for opportunities", 2)
    response.should have_tag("tr>td", "value for objectives", 2)
    response.should have_tag("tr>td", "value for procedures_opening", 2)
    response.should have_tag("tr>td", "value for procedures_engagement", 2)
    response.should have_tag("tr>td", "value for procedures_closure", 2)
    response.should have_tag("tr>td", "value for assessment", 2)
    response.should have_tag("tr>td", "value for reflection", 2)
  end
end

