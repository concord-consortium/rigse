
require File.expand_path('../../../spec_helper', __FILE__)

describe Embeddable::OpenResponse do
  before(:each) do
    @orclass = Embeddable::OpenResponse
  end

  it "should create a new instance with default values" do
    open_response = Embeddable::OpenResponse.create
    open_response.save 
    expect(open_response).to be_valid
  end
  
  describe "validations" do
    it "should validate good values" do
      expect(@orclass.create(:rows => @orclass::MAX_ROWS)).to be_valid
      expect(@orclass.create(:rows => @orclass::MIN_ROWS)).to be_valid
      expect(@orclass.create(:columns => @orclass::MAX_COLUMNS)).to be_valid
      expect(@orclass.create(:columns => @orclass::MIN_COLUMNS)).to be_valid
      expect(@orclass.create(:font_size => @orclass::MAX_FONT_SIZE)).to be_valid
      expect(@orclass.create(:font_size => @orclass::MIN_FONT_SIZE)).to be_valid
    end
    it "should not validate bad balues" do
      expect(@orclass.create(:rows => @orclass::MAX_ROWS + 1)).not_to be_valid
      expect(@orclass.create(:rows => @orclass::MIN_ROWS - 1)).not_to be_valid
      expect(@orclass.create(:columns => @orclass::MAX_COLUMNS + 1)).not_to be_valid
      expect(@orclass.create(:columns => @orclass::MIN_COLUMNS - 1)).not_to be_valid
      expect(@orclass.create(:font_size => @orclass::MAX_FONT_SIZE + 1)).not_to be_valid
      expect(@orclass.create(:font_size => @orclass::MIN_FONT_SIZE - 1)).not_to be_valid
    end
  end


  # TODO: auto-generated
  describe '#by_offering' do
    xit 'by_offering' do
      open_response = described_class.new
      offering = FactoryGirl.create(:portal_offering)
      result = open_response.by_offering(offering)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#by_learner' do
    xit 'by_learner' do
      open_response = described_class.new
      learner = double('learner')
      result = open_response.by_learner(learner)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#first_by_learner' do
    xit 'first_by_learner' do
      open_response = described_class.new
      learner = double('learner')
      result = open_response.first_by_learner(learner)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.searchable_attributes' do
    it 'searchable_attributes' do
      result = described_class.searchable_attributes

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#investigations' do
    it 'investigations' do
      open_response = described_class.new
      result = open_response.investigations

      expect(result).not_to be_nil
    end
  end


end
