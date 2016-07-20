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

    describe "delegates whether the student report" do
      it "is enabled" do
        @investigation.student_report_enabled = true
        @offering.student_report_enabled?.should be_true
      end

      it "is enabled" do
        @investigation.student_report_enabled = false
        @offering.student_report_enabled?.should be_false
      end
    end

    describe "an offering with learners" do
      before (:each) do
        @learner = Factory.build(:portal_learner)
        @learner.stub(:valid?).and_return(true)

        @offering = Factory.create(:portal_offering, 
                                   :runnable => @investigation,
                                   :learners => [@learner])
      end

      # this is probably not a good approach, it makes it heard for cleaning up learner data
      # and assignments when we really want to. It blocks all of the dependent destroy definitions
      # from being used
      it "can not be destroyed" do
        @offering.destroy.should be false
        lambda { @offering.destroy!}.should raise_exception()
      end

    end


  end
  
end
