require File.expand_path('../../../spec_helper', __FILE__)

describe Report::OfferingStudentStatus do
  context "with a learner" do
    let :learner do
      _learner = Object.new
      allow(_learner).to receive_message_chain(:report_learner, :last_run).and_return(@run_date)
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

    describe "never_run" do
      describe '#never_run' do
        subject { super().never_run }
        it { is_expected.to eq(false) }
      end
    end

    describe "last_run_string" do
      describe '#last_run_string' do
        subject { super().last_run_string }
        it { is_expected.to eq("Started, last run Dec 23, 1970")}
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
        it { is_expected.to eq("Not yet started")}
      end
    end
  end

  # TODO: auto-generated
  describe '#display_report_link?' do
    it 'display_report_link?' do
      offering_student_status = described_class.new
      result = offering_student_status.display_report_link?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#offering_reportable?' do
    it 'offering_reportable?' do
      offering_student_status = described_class.new
      result = offering_student_status.offering_reportable?

      expect(result).to be_nil
    end
  end
end
