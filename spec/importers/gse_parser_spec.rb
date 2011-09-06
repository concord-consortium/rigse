require File.expand_path('../../spec_helper', __FILE__)

describe GseParser do
  before(:all) do
    @parser = GseParser.new(:verbose => false)
    @parser.process_rigse_data
    @domains = RiGse::Domain.find(:all)
    @big_ideas = RiGse::BigIdea.find(:all)
    @knowledge_statements = RiGse::KnowledgeStatement.find(:all)
    @grade_span_expectations = RiGse::GradeSpanExpectation.find(:all)
    @expectation_stems = RiGse::ExpectationStem.find(:all)
    @expectations = RiGse::Expectation.find(:all)
    @unifying_themes = RiGse::UnifyingTheme.find(:all)
    @assessment_targets = RiGse::AssessmentTarget.find(:all)
  end

  it "should parse assesment targets" do
    sample_text = 'PS1 (5-8) INQ-1 Investigate the relationships among mass, volume and density.'
    @parser.parse_assessment_target(sample_text).should_not be_nil
    sample_text = 'LS2 (9-11) SAE+FAF -10 Explain how the immune system, endocrine system, or nervous system works and draw conclusions about how systems interact to maintain homeostasis in the human body.'
    @parser.parse_assessment_target(sample_text).should_not be_nil
  end

  it "should parse grade span expectation texts" do
    sample_text = 'Example Extension(s) PS2 (Ext)- 5 Students demonstrate an understanding of energy by\u2026 5aa Identifying, measuring, calculating an'
    @parser.parse_grade_span_expectation(sample_text,@assessment_targets[0]).should_not be_nil
    # sample_text = 'PS1 (K-2) POC -2 Students demonstrate an understanding of states of matter by \u2026 2a describing properties of solids and liquids. 2b identifying and comparing solids and liquids. 2c making logical predictions about the changes in the state of matter when adding or taking away heat (e.g., ice melting, water freezing).'
    # @parser.parse_grade_span_expectation(sample_text,@assessment_targets[0]).should_not be_nil
  end


  it "should not parse some bad entities" do
    sample_text = 'No further targets for EK PS1 at the K-4 Grade Span'
    @parser.parse_assessment_target(sample_text).should be_nil
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
      big.unifying_theme.should be_a_kind_of(RiGse::UnifyingTheme)
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
      ks.domain.should be_a_kind_of(RiGse::Domain)
    end
  end

  it "should create grade span expectations that have an assessment target" do
    @grade_span_expectations.each do |gse|
      gse.assessment_target.should be_a_kind_of(RiGse::AssessmentTarget)
    end
  end

  it "should create grade span expectations that have expectation stems that have expectations" do
    @grade_span_expectations.each do |gse|
      expectation_stems = gse.expectation_stems
      if expectation_stems.length > 0
        expectations = expectation_stems[0].expectations
        if expectations.length > 0
          expectations[0].should be_a_kind_of(RiGse::Expectation)
        end
      end
    end
  end

  it "should create expectation stems that have expectations" do
    @expectation_stems.each do |es|
      ex = es.expectations
      ex[0].should be_a_kind_of(RiGse::Expectation) if ex.length > 0
    end
  end

  it "should create expectations that have an expectation stem" do
    @expectations.each do |ex|
      es = ex.expectation_stem
      es.should be_a_kind_of(RiGse::ExpectationStem)
    end
  end

  it "should create expectations with one expectation_stem that has a description" do
    @expectations.each do |expectation|
      expectation.expectation_stem.description.should_not be_empty
    end
  end

  it "should create expectation_indicators that have ordinal markers" do
    @expectations.each do |expectation|
      expectation.expectation_indicators.each do |expectation_indicator|
        expectation_indicator.ordinal.should_not be_empty
      end
    end
  end
end
