require 'spec_helper'

describe Dataservice::Blob do
  before(:each) do
    @valid_attributes = {
      
    }
  end

  it "should create a new instance given valid attributes" do
    Dataservice::Blob.create!(@valid_attributes)
  end
end
