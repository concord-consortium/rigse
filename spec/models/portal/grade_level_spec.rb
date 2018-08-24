require File.expand_path('../../../spec_helper', __FILE__)

describe Portal::GradeLevel do
  before(:each) do
    grade = Factory(:portal_grade)
    @valid_attributes = {
      :has_grade_levels_id => 1,
      :has_grade_levels_type => "value for has_grade_levels_type",
      :grade_id => grade.id,
      :uuid => "value for uuid"
    }
  end

  it "should create a new instance given valid attributes" do
    Portal::GradeLevel.create!(@valid_attributes)
  end


  # TODO: auto-generated
  describe '.searchable_attributes' do
    it 'searchable_attributes' do
      result = described_class.searchable_attributes

      expect(result).not_to be_nil
    end
  end


end
