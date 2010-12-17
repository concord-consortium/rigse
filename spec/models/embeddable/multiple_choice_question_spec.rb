require 'spec_helper'

describe Embeddable::MultipleChoice do
  it_should_behave_like 'a cloneable model'
  before(:each) do
    @page = Factory(:page)
    @user = Factory(:user)
    @multichoice = Factory(:multiple_choice)
    @multichoice.pages << @page
    @multichoice.user = @user
    @multichoice.save
    @multichoice.reload
  end

  describe "a newly created MutipleChoiceQuestion" do    
    it "should have a non-blank propt" do
      @multichoice.prompt.should_not be_nil
    end
    
    it "should have a user" do
      @multichoice.user.should_not be_nil
      @multichoice.user.should == @user
    end
    
    it "should belong to a page" do
      @multichoice.pages.should_not be_nil
      @multichoice.pages.should include(@page)
    end
    
    it "should have three initial default answers" do
      @multichoice.choices.should have(3).answers
    end
  end

  describe "adding a new choice" do
    before(:each) do
      @choice = @multichoice.addChoice("my choice")
      @multichoice.reload
    end
    
    it "should have the new choice" do
      @multichoice.choices.should include(@choice)
    end
  
    it "should update its choices when saved" do
      @choice.choice = "fooo"
      @choice.save
      @multichoice.reload
      @multichoice.choices[3].choice.should == "fooo"
    end
      
  end

end
