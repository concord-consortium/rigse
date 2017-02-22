require File.expand_path('../../../spec_helper', __FILE__)



describe Embeddable::MultipleChoice do
  before(:each) do
    @page = Factory(:page)
    @user = Factory(:user)
    @multichoice = Factory(:multiple_choice)
    @multichoice.pages << @page
    @multichoice.user = @user
    @multichoice.save
    @multichoice.create_default_choices
    @multichoice.reload
  end

  describe "a newly created MutipleChoiceQuestion" do    
    it "should have a non-blank propt" do
      expect(@multichoice.prompt).not_to be_nil
    end
    
    it "should have a user" do
      expect(@multichoice.user).not_to be_nil
      expect(@multichoice.user).to eq(@user)
    end
    
    it "should belong to a page" do
      expect(@multichoice.pages).not_to be_nil
      expect(@multichoice.pages).to include(@page)
    end
    
    it "should have three initial default answers" do
      expect(@multichoice.choices.size).to eq(3)
    end
  end

  describe "adding a new choice" do
    before(:each) do
      @choice = @multichoice.addChoice("my choice")
      @multichoice.reload
    end
    
    it "should have the new choice" do
      expect(@multichoice.choices).to include(@choice)
    end
  
    it "should update its choices when saved" do
      @choice.choice = "fooo"
      @choice.save
      @multichoice.reload
      expect(@multichoice.choices[3].choice).to eq("fooo")
    end
      
  end

end
