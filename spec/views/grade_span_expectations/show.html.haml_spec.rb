require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/grade_span_expectations/show.html.haml" do
  
  before(:each) do
    @assessment_target_unifying_theme = stub_model(AssessmentTargetUnifyingTheme)
    @domain = stub_model(Domain, :id => 1, :name => "Physical Science")
    @big_idea = stub_model(BigIdea, :id => 1, :description => "Explore")
    @unifying_theme = stub_model(UnifyingTheme, :id => 1, :name => "Curiosity")
    @assessment_target = stub_model(AssessmentTarget, :id => 2, :number => 3)
    @knowledge_statement = stub_model(KnowledgeStatement, :id => 1, :description => "I can see the world around me.")

    @grade_span_expectation = stub_model(GradeSpanExpectation, :id => 3)

    @knowledge_statement.domain = @domain
    @assessment_target_unifying_theme.unifying_theme = @unifying_theme
    @assessment_target_unifying_theme.assessment_target = @assessment_target
    @assessment_target.knowledge_statement = @knowledge_statement
    @grade_span_expectation.assessment_target = @assessment_target
    
    assigns[:grade_span_expectation] = @grade_span_expectation
  end

  it "should render attributes in <p>" do
    pending "Broken example"
    render "/grade_span_expectations/show.html.haml"
  end
end

