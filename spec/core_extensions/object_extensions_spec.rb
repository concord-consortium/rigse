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

class RandomClass; end

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

  describe "when a plain old object doesn't define its own method" do
    it "should use Class.name.humaize.titlecase" do
      instance = RandomClass.new
      expect(instance.display_name).to eq(RandomClass.name.humanize.titlecase)
    end
  end

  describe "when an ActiveModel class does not define its own #display_name" do
    it "should use the global class method" do
      instance = TestClass.new
      expect(TestClass.display_name).to eq('Test Class')
      expect(instance.class.display_name).to eq('Test Class')
    end
  end

  describe "when the object does define its own #display_name" do
    it "should not call LocalNames.instance#local_name_for" do
      instance = HasOwnDisplayName.new
      expect(instance).not_to receive(:display_name)
      expect(instance.class.display_name).to eq(HasOwnDisplayName::DisplayNameValue)
      expect(HasOwnDisplayName.display_name).to eq(HasOwnDisplayName::DisplayNameValue)
    end
  end

  describe 'when the model is part of a module' do
    it 'should not include the module name as part of the #display_name' do
      instance = TestModule::InnerTest::TestClass.new
      expect(instance.class.display_name).to eq('Test Class')
    end
  end
end
