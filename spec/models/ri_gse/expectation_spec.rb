require File.expand_path('../../../spec_helper', __FILE__)

describe RiGse::Expectation do
  before(:each) do
    @expectation = RiGse::Expectation.new
    @valid_attributes = {
    }
  end

  it "should create a new instance given valid attributes" do
    RiGse::Expectation.create!(@valid_attributes)
  end
  
  it "should have an grade_span_expectation" do
    exp = RiGse::Expectation.create!(@valid_attributes)
    gse = RiGse::GradeSpanExpectation.new
    exp.grade_span_expectation = gse
  end
  
  it "should have an grade_span_expectation" do
    gse = RiGse::GradeSpanExpectation.new
    gse.save
    @expectation.grade_span_expectation = gse
    expect(@expectation.grade_span_expectation).not_to be_nil
    @expectation.save
  end
  
  it "should have a a stem" do
    stem = RiGse::ExpectationStem.new
    stem.save
    @expectation.expectation_stem = stem
    expect(@expectation.expectation_stem).not_to be_nil
    @expectation.save
  end
  
  it "should have many indicators" do
    one = RiGse::ExpectationIndicator.new();
    one.description = "first one"
    two = RiGse::ExpectationIndicator.new();
    two.description = "second one"
    one.save
    two.save
    @expectation.expectation_indicators << one
    @expectation.expectation_indicators << two
    expect(@expectation.expectation_indicators.size).to be(2) 
    @expectation.save
  end
  
end
