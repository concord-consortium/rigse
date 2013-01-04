require File.expand_path('../../../spec_helper', __FILE__)

describe Report::OfferingStudentStatus do
  context "with a learner" do
    let :learner do
      _learner = Object.new
      _learner.stub_chain(:report_learner, :last_run).and_return(@run_date)
      _learner
    end
    let(:offering) {nil }

    subject do 
      @run_date = Date.new(1970,12,23)
      status = Report::OfferingStudentStatus.new
      status.learner = learner
      status.offering = offering
      status
    end
    
    describe "last_run" do
      its(:last_run){should == @run_date}
    end

    describe "complete_percent" do
      # possibly an error condition ...
      context "when the offering isn't reportable" do
        let :offering do
          _offering = Object.new
          _offering.stub!(:individual_reportable?).and_return(false)
          _offering
        end
        its(:complete_percent){should == 99.99}
      end
      context "when the offering is reportable" do
        let :offering do
          _offering = Object.new
          _offering.stub!(:individual_reportable?).and_return(true)
          _offering
        end
        context "without a complete_percent in report_learner" do
          let :learner do
            _learner = Object.new
            _learner.stub_chain(:report_learner,:complete_percent).and_return(nil)
            _learner
          end
          its(:complete_percent){should == 0}
      
        end
        context "with a 50% complete_percent in report_learner" do
          let :learner do
            _learner = Object.new
            _learner.stub_chain(:report_learner,:complete_percent).and_return(50)
            _learner
          end
          its(:complete_percent){should == 50}
        end
      end
    end

    describe "never_run" do
      its(:never_run){ should == false }
    end

    describe "last_run_string" do
      its(:last_run_string) { should == "Last run Dec 23, 1970"}
    end
  end


  context "without a learner" do
    subject do      
      status = Report::OfferingStudentStatus.new
      status.learner = nil
      status
    end
    
    # TODO: What kind of behavior do we want without a learner?
    describe "last_run" do
      its(:last_run){should be_nil}
    end
    
    describe "never_run" do
      its(:never_run){ should == true }
    end

    describe "last_run_string" do
      its(:last_run_string) { should == "not yet started"}
    end
  end
 
end
