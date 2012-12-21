require File.expand_path('../../../spec_helper', __FILE__)

describe Report::OfferingStudentStatus do
  context "with a learner" do
    subject do 
      learner = Object.new
      @run_date = Date.new(1970,12,23)
      learner.stub_chain(:report_learner, :last_run).and_return(@run_date)
      status = Report::OfferingStudentStatus.new
      status.learner = learner
      status
    end
    
    describe "last_run" do
      its(:last_run){should == @run_date}
    end

    describe "complete_percent" do
    # pending
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