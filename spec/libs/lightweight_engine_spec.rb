require File.expand_path('../../spec_helper', __FILE__)

describe Lightweight::Engine do
  describe "It can find models and controllers it needs" do
    it "can call the Portal::OfferingsController#answers action" do
      Portal::OfferingsController.action_methods.include?('answers').should be true
    end
    
    it "can find prompts in and answers to Embeddable::MultipleChoice questions" do
      @multichoice = Factory(:multiple_choice)
      @multichoice.create_default_choices
      @multichoice.prompt.should_not be_nil
      @multichoice.choices.should have(3).answers
    end

    it "should find valid Embeddable::OpenResponse questions" do
      open_response = Embeddable::OpenResponse.create
      open_response.save 
      open_response.should be_valid
    end

    it "should find Portal::Offering objects with runnables" do
      @offering = Portal::Offering.new
      @offering.respond_to?('runnable').should be true
    end

    it "should find Saveable objects with answers" do
      @multichoice = Factory(:saveable_multiple_choice)
      @open_response = Factory(:saveable_open_response)
      @multichoice.respond_to?('answer').should be true
      @open_response.respond_to?('answer').should be true
    end
  end
end