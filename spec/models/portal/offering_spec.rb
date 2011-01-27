require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Portal::Offering do
  before(:each) do
    @investigation = Factory.create(:investigation)
  end
  
  describe "when being created" do
    before(:each) do
      @offering = Portal::Offering.new
    end
  end
  
  describe "after being created" do
    before(:each) do
      @offering = Factory.create(:portal_offering, :runnable => @investigation)
    end
    
    it "should be active by default" do
      @offering.active.should be_true
      @offering.active?.should be_true
    end
    
    it "can be deactivated" do
      @offering.active?.should be_true
      @offering.deactivate!
      
      @offering.active.should be_false
      @offering.active?.should be_false
    end
    
    it "can be activated" do
      @offering.deactivate!
      @offering.active?.should be_false
      
      @offering.activate!
      @offering.active?.should be_true
    end
  end
  
end