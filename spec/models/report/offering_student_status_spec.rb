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
      describe '#last_run' do
        subject { super().last_run }
        it {is_expected.to eq(@run_date)}
      end
    end

    describe "complete_percent" do
      # possibly an error condition ...
      context "when the offering isn't reportable" do
        let :offering do
          _offering = Object.new
          allow(_offering).to receive(:individual_reportable?).and_return(false)
          _offering
        end

        describe '#complete_percent' do
          subject { super().complete_percent }
          it {is_expected.to eq(99.99)}
        end
      end
      context "when the offering is reportable" do
        let :offering do
          _offering = Object.new
          allow(_offering).to receive(:individual_reportable?).and_return(true)
          _offering
        end
        context "without a complete_percent in report_learner" do
          let :learner do
            _learner = Object.new
            _learner.stub_chain(:report_learner,:complete_percent).and_return(nil)
            _learner
          end

          describe '#complete_percent' do
            subject { super().complete_percent }
            it {is_expected.to eq(0)}
          end
      
        end
        context "with a 50% complete_percent in report_learner" do
          let :learner do
            _learner = Object.new
            _learner.stub_chain(:report_learner,:complete_percent).and_return(50)
            _learner
          end

          describe '#complete_percent' do
            subject { super().complete_percent }
            it {is_expected.to eq(50)}
          end
        end
      end
    end

    describe "never_run" do
      describe '#never_run' do
        subject { super().never_run }
        it { is_expected.to eq(false) }
      end
    end

    describe "last_run_string" do
      describe '#last_run_string' do
        subject { super().last_run_string }
        it { is_expected.to eq("Last run Dec 23, 1970")}
      end
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
      describe '#last_run' do
        subject { super().last_run }
        it {is_expected.to be_nil}
      end
    end
    
    describe "never_run" do
      describe '#never_run' do
        subject { super().never_run }
        it { is_expected.to eq(true) }
      end
    end

    describe "last_run_string" do
      describe '#last_run_string' do
        subject { super().last_run_string }
        it { is_expected.to eq("not yet started")}
      end
    end
  end
 
end
