require File.expand_path('../../../../spec_helper', __FILE__)

describe "/ri_gse/grade_span_expectations/index.html.haml" do
  
  before(:each) do
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
    # do this so will_paginate handles this array, there is probably a better approach
    @gses.stub(:total_pages).and_return(1)
    RiGse::GradeSpanExpectation.stub!(:paginate).and_return(@gses)
    assign(:grade_span_expectations, @gses)
  end

  it "should render list of grade_span_expectations" do
    render
    # TODO: Assert something about what we just rendered!
  end
end

