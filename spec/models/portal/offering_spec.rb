require File.expand_path('../../../spec_helper', __FILE__)

describe Portal::Offering do
  
  describe "after being created" do
    let(:runnable) { Factory.create(:investigation) }
    let(:args)     { {runnable: runnable} }
    let(:offering) { Factory.create(:portal_offering, args) }

    it "should be active by default" do
     expect(offering.active).to be_truthy
     expect(offering.active?).to be_truthy
    end
    
    it "can be deactivated" do
     expect(offering.active?).to be_truthy
     offering.deactivate!
      
     expect(offering.active).to be_falsey
     expect(offering.active?).to be_falsey
    end
    
    it "can be activated" do
     offering.deactivate!
     expect(offering.active?).to be_falsey
      
     offering.activate!
     expect(offering.active?).to be_truthy
    end

    describe "should_be_shown" do
      describe "when the runable is archived" do
        before(:each) { allow(runnable).to receive(:archived?).and_return(true) }
        it "should always be deactivated" do
          expect(offering.should_show?).to be_falsey
        end
        it "should still be deactivated after activating" do
          offering.activate!
          expect(offering.should_show?).to be_falsey
        end
      end
    end

    describe "delegates whether the student report" do
      it "is enabled" do
        runnable.student_report_enabled = true
        expect(offering.student_report_enabled?).to be_truthy
      end

      it "is disabled" do
        runnable.student_report_enabled = false
        expect(offering.student_report_enabled?).to be_falsey
      end
    end

    describe "an offering with learners" do
      let(:learner) { Factory.build(:portal_learner) }
      let(:args)    { {runnable: runnable, learners: [learner]} }
      before(:each) { allow(learner).to receive(:valid?).and_return(true) }

      # this is probably not a good approach, it makes it heard for cleaning up learner data
      # and assignments when we really want to. It blocks all of the dependent destroy definitions
      # from being used
      it "can not be destroyed" do
       expect(offering.destroy).to be false
        expect {offering.destroy!}.to raise_exception()
      end

    end


  end
  
end
