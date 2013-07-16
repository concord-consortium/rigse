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
  # stub ActiveModel method
  def self.model_name
    ActiveModel::Name.new(TestClass)
  end
end

module TestModule
  module InnerTest
    class TestClass
      # stub ActiveModel method
      def self.model_name
        ActiveModel::Name.new(TestClass)
      end
    end
  end
end

describe "Object#display_name" do
  describe "when the class does not define its own #display_name" do
    it "should use the global class method" do
      instance = TestClass.new
      TestClass.display_name.should == 'Test Class'
      instance.class.display_name.should == 'Test Class'
    end
  end

  describe "when the object does define its own #display_name" do
    it "should not call LocalNames.instance#local_name_for" do
      instance = HasOwnDisplayName.new
      instance.should_not_receive(:display_name)
      instance.class.display_name.should == HasOwnDisplayName::DisplayNameValue
      HasOwnDisplayName.display_name.should == HasOwnDisplayName::DisplayNameValue
    end
  end

  describe 'when the model is part of a module' do
    it 'should not include the module name as part of the #display_name' do
      instance = TestModule::InnerTest::TestClass.new
      instance.class.display_name.should == 'Test Class'      
    end
  end
end
