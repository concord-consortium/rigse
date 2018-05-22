require File.expand_path('../../spec_helper', __FILE__)

describe BoolENV do
  ["True","true","Yes","yes","1"].each do |truthy_value|
    it "should return true for variable with value #{truthy_value}" do
      ENV.stub(:[]).with("test_var").and_return(truthy_value)
      expect(BoolENV["test_var"]).to be true
    end
  end
  it "should return false for variable not set" do
    expect(BoolENV["test_var"]).to be false
  end
  ["","False","false","No","no","0","random text"].each do |falsy_value|
    it "should return false for variable with value #{falsy_value}" do
      ENV.stub(:[]).with("test_var").and_return(falsy_value)
      expect(BoolENV["test_var"]).to be false
    end
  end
end
