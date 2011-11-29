require File.expand_path('../../spec_helper', __FILE__)


class HasOwnDisplayName
  DisplayNameValue="Testing 123456789"
  def display_name
    DisplayNameValue
  end
  def self.display_name
    DisplayNameValue
  end
end

class TestClass
end

describe "Object#display_name" do
  before(:each) do
    @mock = mock(:local_name_instance)
    LocalNames.stub!(:instance).and_return(@mock)  
  end
  describe "when the object does not define its own #display_name" do
    it "should call LocalNames.instance#local_name_for" do
      instance = TestClass.new
      @mock.should_receive(:local_name_for).and_return("foo")
      instance.display_name.should == "foo"
    end
  end
  describe "when the object does define its own #display_name" do
    it "should not call LocalNames.instance#local_name_for" do
      instance = HasOwnDisplayName.new
      @mock.should_not_receive(:local_name_for)
      instance.display_name.should == HasOwnDisplayName::DisplayNameValue
      HasOwnDisplayName.display_name.should == HasOwnDisplayName::DisplayNameValue
    end
  end
end
