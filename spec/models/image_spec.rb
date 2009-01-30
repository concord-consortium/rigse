require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Image do
  before(:each) do
    @valid_attributes = {
      :integer => ,
      :string => ,
      :string => ,
      :string => ,
      :integer => ,
      :integer => ,
      :integer => ,
      :string => 
    }
  end

  it "should create a new instance given valid attributes" do
    Image.create!(@valid_attributes)
  end
end
