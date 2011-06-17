require File.expand_path('../../../spec_helper', __FILE__)

describe MavenJnlp::Property do
  before(:each) do
    @valid_attributes = {
      :uuid => "value for uuid",
      :name => "value for name",
      :value => "value for value",
      :os => "value for os"
    }
  end

  it "should create a new instance given valid attributes" do
    MavenJnlp::Property.create!(@valid_attributes)
  end
end
