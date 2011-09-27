require 'spec_helper'

describe Admin::Tag do
  before(:each) do
    @valid_attributes = {
      :scope => "value for scope",
      :tag => "value for tag"
    }
  end

  it "should create a new instance given valid attributes" do
    Admin::Tag.create!(@valid_attributes)
  end
end
