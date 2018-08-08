require File.expand_path('../../../spec_helper', __FILE__)

describe Saveable::SaveableStandin do
  # it_should_behave_like 'a saveable'
  # Not quite -- in this case, there is no embeddable
  before(:each) do
    @nil_standin = Saveable::SaveableStandin.new
    @multiple_choice = Embeddable::MultipleChoice.new
    @real_standin = Saveable::SaveableStandin.new(@multiple_choice)
  end

  it "should resond to embeddable" do
    expect(@nil_standin).to respond_to :embeddable
  end

  it "should respond to submitted?" do
    expect(@nil_standin).to respond_to :submitted?
  end

  it "should optionally return its embeddable" do
    expect(@nil_standin.embeddable).to be_nil
    expect(@real_standin.embeddable).to eq(@multiple_choice)
  end

end
