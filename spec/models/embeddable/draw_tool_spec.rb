require 'spec_helper'
describe Embeddable::DrawingTool do
  def create(attributes)
    Embeddable::DrawingTool.create(attributes)
  end

  before(:each) do
    @valid_attributes={
      :name => 'drawing tool test',
      :description => 'drawing tool test',
      :background_image_url => 'http://someplace.com/image.jpg' #TODO: validate?
    }
  end
  
  it_should_behave_like 'an embeddable'

  describe "field validations" do
    it "should create a new instance given valid attributes" do
      test_case = create(@valid_attributes)
      test_case.should be_valid
    end
  end

end
