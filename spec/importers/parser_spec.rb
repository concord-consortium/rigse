require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


describe Parser do
  before(:all) do
    @parser = Parser.new
    @parser.process_rigse_data
    @domains = Domain.find(:all)
    @big_ideas = BigIdea.find(:all)
    @knowledge_statements = KnowledgeStatement.find(:all)
    @grade_span_expectations = GradeSpanExpectation.find(:all)
    @expectation_stems = ExpectationStem.find(:all)
    @expectations = Expectation.find(:all)
    @unifying_themes = UnifyingTheme.find(:all)
    @assessment_targets = AssessmentTarget.find(:all)
  end

  it "should parse assesment targets" do
    sample_text = 'PS1 (5-8) INQ-1 Investigate the relationships among mass, volume and density.'
    @parser.parse_assesment_target(sample_text).should_not be_nil
  end

  it "should parse grade span expectation texts" do
    sample_text = 'Example Extension(s) PS2 (Ext)– 5 Students demonstrate an understanding of energy by… 5aa Identifying, measuring, calculating an'
    @parser.parse_grade_span_expectation(sample_text,@assessment_targets[0]).should_not be_nil
    sample_text = 'PS1 (K-2) POC –2 Students demonstrate an understanding of states of matter by … 2a describing properties of solids and liquids. 2b identifying and comparing solids and liquids. 2c making logical predictions about the changes in the state of matter when adding or taking away heat (e.g., ice melting, water freezing).'
    @parser.parse_grade_span_expectation(sample_text,@assessment_targets[0]).should_not be_nil
  end


  it "should not parse some bad entities" do
    sample_text = 'No further targets for EK PS1 at the K-4 Grade Span'
    @parser.parse_assesment_target(sample_text).should be_nil
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
      big.unifying_theme.should be_a_kind_of(UnifyingTheme)
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
      es = ex.expectation_stem
      es.should be_a_kind_of(ExpectationStem)
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
      ex_stem.stem.should_not be_empty
    end
  end

end
