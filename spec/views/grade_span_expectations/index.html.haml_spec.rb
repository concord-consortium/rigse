require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
describe "/grade_span_expectations/index.html.haml" do

  before(:each) do
    generate_default_project_and_jnlps_with_factories
    target = mock('target', :number => 1, :description => "nothing here", :knowledge_statement => nil, :unifying_themes => [])
    domain = mock('domain')
    canned_responses = {
      :assessment_target => target,
      :domain => domain,
      :expectations => [],
      :gse_key => "GSE_KEY",
      :grade_span => "k-12",
      :number => 1
    }
    @gses = [
      mock_model(RiGse::GradeSpanExpectation,canned_responses),
      mock_model(RiGse::GradeSpanExpectation,canned_responses)
    ];
    RiGse::GradeSpanExpectation.stub!(:paginate).and_return(@gses.paginate)
    assigns[:grade_span_expectations] = @gses.paginate
  end

  it "should render list of grade_span_expectations" do
    render "/ri_gse/grade_span_expectations/index.html.haml"
    # TODO: Assert something about what we just rendered!
  end
end

