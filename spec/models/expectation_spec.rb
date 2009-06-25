require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Expectation do
  before(:each) do
    @expectation = Expectation.new
    @valid_attributes = {
    }
  end

  it "should create a new instance given valid attributes" do
    Expectation.create!(@valid_attributes)
  end
  
  it "should have an grade_span_expectation" do
    exp = Expectation.create!(@valid_attributes)
    gse = GradeSpanExpectation.new
    exp.grade_span_expectation = gse
  end
  
  it "should have an grade_span_expectation" do
    gse = GradeSpanExpectation.new
    gse.save
    @expectation.grade_span_expectation = gse
    @expectation.grade_span_expectation.should_not be_nil
    @expectation.save
  end
  
  it "should have a a stem" do
    stem = ExpectationStem.new
    stem.save
    @expectation.expectation_stem = stem
    @expectation.expectation_stem.should_not be_nil
    @expectation.save
  end
  
  it "should have many indicators" do
    one = ExpectationIndicator.new();
    one.description = "first one"
    two = ExpectationIndicator.new();
    two.description = "second one"
    one.save
    two.save
    @expectation.expectation_indicators << one
    @expectation.expectation_indicators << two
    @expectation.expectation_indicators.size.should be(2) 
    @expectation.save
  end
  
end
