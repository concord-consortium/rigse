require File.expand_path('../../../spec_helper', __FILE__)

describe Portal::Offering do
  
  describe "after being created" do
    let(:runnable) { Factory.create(:investigation) }
    let(:args)     { {runnable: runnable} }
    let(:offering) { Factory.create(:portal_offering, args) }

    it "should be active by default" do
     offering.active.should be_true
     offering.active?.should be_true
    end
    
    it "can be deactivated" do
     offering.active?.should be_true
     offering.deactivate!
      
     offering.active.should be_false
     offering.active?.should be_false
    end
    
    it "can be activated" do
     offering.deactivate!
     offering.active?.should be_false
      
     offering.activate!
     offering.active?.should be_true
    end

    describe "should_be_shown" do
      describe "when the runable is archived" do
        before(:each) { runnable.stub(:archived?).and_return(true) }
        it "should always be deactivated" do
          offering.should_show?.should be_false
        end
        it "should still be deactivated after activating" do
          offering.activate!
          offering.should_show?.should be_false
        end
      end
    end

    describe "delegates whether the student report" do
      it "is enabled" do
        runnable.student_report_enabled = true
       offering.student_report_enabled?.should be_true
      end

      it "is enabled" do
        runnable.student_report_enabled = false
       offering.student_report_enabled?.should be_false
      end
    end

    describe "an offering with learners" do
      let(:learner) { Factory.build(:portal_learner) }
      let(:args)    { {runnable: runnable, learners: [learner]} }
      before(:each) { learner.stub(:valid?).and_return(true) }

      # this is probably not a good approach, it makes it heard for cleaning up learner data
      # and assignments when we really want to. It blocks all of the dependent destroy definitions
      # from being used
      it "can not be destroyed" do
       offering.destroy.should be false
        lambda {offering.destroy!}.should raise_exception()
      end

    end


  end
  
end
