require File.expand_path('../../../spec_helper', __FILE__)

describe Saveable::SaveableStandin do
  #it_should_behave_like 'a saveable'
  # Not quite -- in this case, there is no embeddable
  before(:each) do
    @nil_standin = Saveable::SaveableStandin.new
    @multiple_choice = Embeddable::MultipleChoice.new
    @real_standin = Saveable::SaveableStandin.new(@multiple_choice)
  end

  it "should resond to embeddable" do
    @nil_standin.should respond_to :embeddable
  end

  it "should optionally return itsembeddable" do
    @nil_standin.embeddable.should be_nil
    @real_standin.embeddable.should == @multiple_choice
  end

end
