require File.expand_path('../../../spec_helper', __FILE__)

describe Dataservice::ConsoleLogger do
  before(:each) do
    @valid_attributes = {
      
    }
  end

  it "should create a new instance given valid attributes" do
    Dataservice::ConsoleLogger.create!(@valid_attributes)
  end


  # TODO: auto-generated
  describe '.searchable_attributes' do
    it 'searchable_attributes' do
      result = described_class.searchable_attributes

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#user' do
    it 'user' do
      console_logger = described_class.new
      result = console_logger.user

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#name' do
    it 'name' do
      console_logger = described_class.new
      result = console_logger.name

      expect(result).not_to be_nil
    end
  end


end
