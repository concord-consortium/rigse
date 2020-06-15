require File.expand_path('../../../spec_helper', __FILE__)

def setupReportables
  page = Page.create()
  section = Section.create()
  embeddables.each do |emb|
    page.add_embeddable(emb)
  end
  section.pages << page
  runnable.sections << section
  runnable.save
end

describe Reports::Detail do
  let(:class_id)         { 23  }
  let(:runnable_name)    { "fake runnable" }
  let(:embeddables)       { [] }
  let(:student)          { FactoryBot.create(:portal_student)  }
  let(:runnable)         { FactoryBot.create(:activity, name: runnable_name)  }
  let(:offering)         { FactoryBot.create(:portal_offering, runnable: runnable)   }
  let(:learner)          { FactoryBot.create(:portal_learner, student: student, offering: offering)  }
  let(:report_learner)   { learner.report_learner }
  let(:url_helpers)      { double(remote_endpoint_url: "noplace.com") }
  let(:runnables)        { [ runnable ] }
  let(:report_learners)  { [ report_learner ] }
  let(:opts) do
    {
      runnables: runnables,
      url_helpers: url_helpers,
      report_learners: report_learners
    }
  end
  let(:report) { Reports::Detail.new(opts) }
  describe '#initialize' do
    it 'asigns values' do
      expect(report.instance_variable_get(:@runnables)).to eq(runnables)
      expect(report.instance_variable_get(:@report_learners)).to eq(report_learners)
      expect(report.instance_variable_get(:@url_helpers)).to eq(url_helpers)
    end
  end
  describe '#run_report' do
    let(:embeddable)  { Embeddable::OpenResponse.create() }
    let(:embeddables) { [embeddable]     }
    let(:stream)      { StringIO.new     }
    let(:answerKey)   { "#{embeddable.class.to_s}|#{embeddable.id}" }
    let(:answers)     { {answerKey => mock_answer } }

    before(:each) do
      setupReportables()
      allow(report_learner).to receive(:answers) { answers }
    end

    describe "with a complete answer" do
      let(:mock_answer)  {{ answer: "my answer" }}
      it 'should not raise an excpetion' do
        expect{report.run_report}.to_not raise_error
      end
    end

    describe "with a null answer" do
      let(:mock_answer)  {{ answer: nil }}
      it 'should STILL not raise an excpetion' do
        expect{report.run_report}.to_not raise_error
      end
    end
  end
end
