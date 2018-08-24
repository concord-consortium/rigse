require File.expand_path('../../../spec_helper', __FILE__)

describe RiGse::AssessmentTarget do
  before(:each) do
    @valid_attributes = {
    }
  end

  it "should create a new instance given valid attributes" do
    RiGse::AssessmentTarget.create!(@valid_attributes)
  end


  # TODO: auto-generated
  describe '.searchable_attributes' do
    it 'searchable_attributes' do
      result = described_class.searchable_attributes

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#add_unifying_theme' do
    xit 'add_unifying_theme' do
      assessment_target = described_class.new
      theme = ('theme')
      result = assessment_target.add_unifying_theme(theme)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#has_unifying_theme?' do
    xit 'has_unifying_theme?' do
      assessment_target = described_class.new
      theme = ('theme')
      result = assessment_target.has_unifying_theme?(theme)

      expect(result).not_to be_nil
    end
  end


end
