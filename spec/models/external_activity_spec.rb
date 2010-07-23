require 'spec_helper'

describe ExternalActivity do
  before(:each) do
    @valid_attributes = {
      :user_id => 1,
      :uuid => "value for uuid",
      :name => "value for name",
      :description => "value for description",
      :publication_status => "value for publication_status"
    }
  end

  it "should create a new instance given valid attributes" do
    ExternalActivity.create!(@valid_attributes)
  end
end
