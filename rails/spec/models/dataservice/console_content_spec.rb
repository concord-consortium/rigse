require File.expand_path('../../../spec_helper', __FILE__)

describe Dataservice::ConsoleContent do
  before(:each) do
    @valid_attributes = {
      :body => "value for body"
    }
  end

  it "should create a new instance given valid attributes" do
    Dataservice::ConsoleContent.create!(@valid_attributes)
  end


  # TODO: auto-generated
  describe '.searchable_attributes' do
    it 'searchable_attributes' do
      result = described_class.searchable_attributes

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#session_uuid' do
    it 'session_uuid' do
      console_content = described_class.new
      result = console_content.session_uuid

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#session_start' do
    it 'session_start' do
      console_content = described_class.new
      result = console_content.session_start

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#session_stop' do
    it 'session_stop' do
      console_content = described_class.new
      result = console_content.session_stop

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#parsed_body' do
    it 'parsed_body' do
      console_content = described_class.new
      result = console_content.parsed_body

      expect(result).not_to be_nil
    end
  end


end
