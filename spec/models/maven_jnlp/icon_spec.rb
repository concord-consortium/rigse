require File.expand_path('../../../spec_helper', __FILE__)

describe MavenJnlp::Icon do
  before(:each) do
    @valid_attributes = {
      :uuid => "value for uuid",
      :name => "value for name",
      :href => "value for href",
      :height => 1,
      :width => 1
    }
  end

  it "should create a new instance given valid attributes" do
    MavenJnlp::Icon.create!(@valid_attributes)
  end
end
