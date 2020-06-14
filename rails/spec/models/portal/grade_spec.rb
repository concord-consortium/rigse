require File.expand_path('../../../spec_helper', __FILE__)

describe Portal::Grade do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :description => "value for description",
      :position => 1,
      :uuid => "value for uuid"
    }
  end

  it "should create a new instance given valid attributes" do
    Portal::Grade.create!(@valid_attributes)
  end

  # TODO: auto-generated
  describe '.active' do # scope test
    it 'supports named scope active' do
      expect(described_class.limit(3).active).to all(be_a(described_class))
    end
  end

  # TODO: auto-generated
  describe '.searchable_attributes' do
    it 'searchable_attributes' do
      result = described_class.searchable_attributes

      expect(result).not_to be_nil
    end
  end


end
