require File.expand_path('../../spec_helper', __FILE__)

describe PageElement do

  before(:each) do
    @page_element = Factory :page_element
    @user = Factory :user
  end
  
  it "should not be nil" do
    expect(@page_element).not_to be_nil
  end
  
  it "not original have an owner" do
    expect(@page_element.user).to be_nil
  end
  
  it "should let an onwer be assinged to it" do
    @page_element.user = @user
    expect(@page_element.user).to be(@user)
  end
  
  it "should persist its owner information" do
    @page_element.user = @user
    @page_element.save
    @page_element.reload
    expect(@page_element.user).not_to be_nil
    expect(@page_element.user).to eq(@user)
  end
  
  it "should be changable by its owner" do
    @page_element.user = @user
    expect(@page_element).to be_changeable(@user)
  end
  

  # TODO: auto-generated
  describe '.page_by_investigation' do # scope test
    it 'supports named scope page_by_investigation' do
      expect(described_class.limit(3).page_by_investigation(Investigation.new(id: 1))).to all(be_a(described_class))
    end
  end
  # TODO: auto-generated
  describe '.student_only' do # scope test
    # not useable without merge
    xit 'supports named scope student_only' do
      expect(described_class.limit(3).student_only).to all(be_a(described_class))
    end
  end
  # TODO: auto-generated
  describe '.by_type' do # scope test
    it 'supports named scope by_type' do
      expect(described_class.limit(3).by_type([])).to all(be_a(described_class))
    end
  end

  # TODO: auto-generated
  describe '.by_investigation' do
    it 'by_investigation' do
      investigation = FactoryGirl.create(:investigation)
      result = described_class.by_investigation(investigation)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.cloneable_associations' do
    it 'cloneable_associations' do
      result = described_class.cloneable_associations

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#check_for_other_references' do
    xit 'check_for_other_references' do
      page_element = described_class.new
      result = page_element.check_for_other_references

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#dom_id' do
    it 'dom_id' do
      page_element = described_class.new
      result = page_element.dom_id

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#teacher_only?' do
    it 'teacher_only?' do
      page_element = described_class.new
      result = page_element.teacher_only?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#parent' do
    it 'parent' do
      page_element = described_class.new
      result = page_element.parent

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#duplicate' do
    xit 'duplicate' do
      page_element = described_class.new
      result = page_element.duplicate

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#reportable_elements' do
    it 'reportable_elements' do
      page_element = described_class.new
      result = page_element.reportable_elements

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#question_number' do
    xit 'question_number' do
      page_element = described_class.new
      result = page_element.question_number

      expect(result).not_to be_nil
    end
  end


end
