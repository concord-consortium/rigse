require 'spec_helper'
describe Embeddable::Embeddable do
  before(:each) do
    @valid_attributes = {}
  end

  it_should_behave_like 'a cloneable model'
  it "should create a new instance given valid attributes"
  
end

