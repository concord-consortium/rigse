require 'spec_helper'

describe Embeddable::OpenResponse do
  def create(attributes)
    Embeddable::OpenResponse.create(attributes)
  end

  before(:each) do
    @valid_attributes = {
      :prompt => "why is the sky green?"
    } 
  end
  
  it_should_behave_like 'an embeddable'

  describe "field validations" do
    it "should create a new instance given valid attributes" do
      test_case = create(@valid_attributes)
      test_case.should be_valid
    end
  end
end
