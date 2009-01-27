require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Activity do
  before(:each) do
    @valid_attributes = {
      :title => "value for title",
      :context => "value for context",
      :opportunities => "value for opportunities",
      :objectives => "value for objectives",
      :procedures_opening => "value for procedures_opening",
      :procedures_engagement => "value for procedures_engagement",
      :procedures_closure => "value for procedures_closure",
      :assessment => "value for assessment",
      :reflection => "value for reflection"
    }
  end

  it "should create a new instance given valid attributes" do
    Activity.create!(@valid_attributes)
  end
end
