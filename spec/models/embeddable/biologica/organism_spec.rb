require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe Embeddable::Biologica::Organism do
  it_should_behave_like 'a cloneable model'

  before(:each) do
    @organism = Factory(:biologica_organism)
  end

  it "should be creatable" do
  end

  it "should be deletable" do
    @organism.destroy
  end
  
end
