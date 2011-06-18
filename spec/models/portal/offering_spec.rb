require File.expand_path('../../../spec_helper', __FILE__)

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

    describe "an offering with learners" do
      before (:each) do
        # TODO: Why is delete and destroy being called on this association?  It shouldn't be
        @learner = mock_model(Portal::Learner, :valid? => true,:[]= => true, :save => true, :destroy=> false, :delete=>false)
        @offering = Factory.create(:portal_offering, 
                                   :runnable => @investigation,
                                   :learners => [@learner])
      end

      it "can not be destroyed" do
        @learner.destroy.should be false
        lambda { @learner.destroy!}.should raise_exception()
      end

      it "can not be deleted" do
        @learner.delete.should be false
        lambda { @learner.delete!}.should raise_exception()
      end

    end


  end
  
end
