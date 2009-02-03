require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Parser do
  before(:all) do
    @parser = Parser.new
    @parser.process_rigse_data
    @domains = Domain.find(:all)
    @knowledge_statements = KnowledgeStatement.find(:all)
    @grade_span_expectations = GradeSpanExpectation.find(:all)
    @expectation_stems = ExpectationStem.find(:all)
    @expectations = Expectation.find(:all)
    @unifying_themes = UnifyingTheme.find(:all)
    @assessment_targets = AssessmentTarget.find(:all)
  end

  it "should create domains that have names" do
    @domains.each do |d|
      d.name.should_not be_empty
    end
  end

  it "should create domains that have keys" do
    @domains.each do |d|
      d.key.should_not be_empty
    end
  end

  it "should create big ideas that that relate to a unifying theme " do
    @big_ideas.each do |big|
      big.key.should_not be_empty
    end
  end

  it "should create big ideas that have descriptions " do
    @big_ideas.each do |big|
      big.description.should_not be_empty
    end
  end

  it "should create knowledge statements that have numbers" do
    @knowledge_statements.each do |ks|
      ks.number.should be_a_kind_of(Fixnum)
    end
  end

  it "should create knowledge statements that have descriptions" do
    @knowledge_statements.each do |ks|
      ks.description.should_not be_empty
    end
  end

  it "should create knowledge statements that have domains" do
    @knowledge_statements.each do |ks|
      ks.domain.should be_a_kind_of(Domain)
    end
  end

  it "should create grade span expectations that have an assessment target" do
    @grade_span_expectations.each do |gse|
      gse.assessment_target.should be_a_kind_of(AssessmentTarget)
    end
  end

  it "should create expectations that have an expectation stem" do
    @expectations.each do |ex|
      ex.EXPECTATION_STEM.should_be_a_kind_of(AssessmentTarget)
    end
  end

  it "should create expectations that have descriptions" do
    @expectations.each do |ex|
      ex.description.should_not be_empty
    end
  end

  it "should create expectations that have ordinal markers" do
    @expectations.each do |ex|
      ex.ordinal.should_not be_empty
    end
  end

  it "should create expectation_stems that have stems" do
    @expectation_stems.each do |ex_stem|
      ex_stem.expectation_stem.should_not be_empty
    end
  end

end
