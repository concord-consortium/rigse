require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Embeddable::ImageQuestion do
  before(:each) do
  
    @default_prompt = Embeddable::ImageQuestion::default_prompt;
    @valid_attributes = {
      :prompt => "Choose a drawing from your lab book, and enter it here"
    }
    @invalid_attributes = {
      :prompt => ""
    }
  end

  it "should create a new instance with default values" do
    image_question = Embeddable::ImageQuestion.new
    image_question.save 
    image_question.should be_valid
    image_question.prompt.should == @default_prompt
  end
  
  it "should create a new instance with valid attributes" do
    image_question = Embeddable::ImageQuestion.create(@valid_attributes)
    image_question.save
    image_question.should be_valid
  end
 
  it "should not create a new instance without valid attributes" do
    image_question = Embeddable::ImageQuestion.create(@invalid_attributes)
    image_question.save
    image_question.should_not be_valid
  end
end
