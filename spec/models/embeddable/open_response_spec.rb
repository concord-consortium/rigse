
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Embeddable::OpenResponse do
  before(:each) do
    @orclass = Embeddable::OpenResponse
  end

  it "should create a new instance with default values" do
    open_response = Embeddable::OpenResponse.create
    open_response.save 
    open_response.should be_valid
  end
  
  describe "validations" do
    it "should validate good values" do
      @orclass.create(:rows => @orclass::MAX_ROWS).should be_valid
      @orclass.create(:rows => @orclass::MIN_ROWS).should be_valid
      @orclass.create(:columns => @orclass::MAX_COLUMNS).should be_valid
      @orclass.create(:columns => @orclass::MIN_COLUMNS).should be_valid
      @orclass.create(:font_size => @orclass::MAX_FONT_SIZE).should be_valid
      @orclass.create(:font_size => @orclass::MIN_FONT_SIZE).should be_valid
    end
    it "should not validate bad balues" do
      @orclass.create(:rows => @orclass::MAX_ROWS + 1).should_not be_valid
      @orclass.create(:rows => @orclass::MIN_ROWS - 1).should_not be_valid
      @orclass.create(:columns => @orclass::MAX_COLUMNS + 1).should_not be_valid
      @orclass.create(:columns => @orclass::MIN_COLUMNS - 1).should_not be_valid
      @orclass.create(:font_size => @orclass::MAX_FONT_SIZE + 1).should_not be_valid
      @orclass.create(:font_size => @orclass::MIN_FONT_SIZE - 1).should_not be_valid
    end
  end
end
