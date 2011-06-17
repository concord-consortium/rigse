require File.expand_path('../../../spec_helper', __FILE__)

describe Portal::Grade do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :description => "value for description",
      :position => 1,
      :uuid => "value for uuid"
    }
  end

  it "should create a new instance given valid attributes" do
    Portal::Grade.create!(@valid_attributes)
  end
end
