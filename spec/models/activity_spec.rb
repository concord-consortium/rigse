require 'spec_helper'

describe Activity do
  before(:each) do
    @valid_attributes = {
      :name => "test activity",
      :description => "new decription"
    }
  end

  it "should create a new instance given valid attributes" do
    Activity.create!(@valid_attributes)
  end
  
  describe "should be publishable" do
    before(:each) do
      @activity = Activity.create!(@valid_attributes)
    end
    
    it "should not be public by default" do
      @activity.published?.should be(false)
    end
    it "should be public if published" do
      @activity.publish!
      @activity.public?.should be(true)
    end
    
    it "should not be public if unpublished " do
      @activity.publish!
      @activity.public?.should be(true)
      @activity.un_publish!
      @activity.public?.should_not be(true)
    end
  end
  
end
