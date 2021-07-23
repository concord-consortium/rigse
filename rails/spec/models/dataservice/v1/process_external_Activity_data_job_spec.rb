require File.expand_path('../../../../spec_helper', __FILE__)

describe Dataservice::V1::ProcessExternalActivityDataJob do
  let(:template)     { double({open_responses: [], multiple_choices: [], image_questions: [], iframes: []}) }
  let(:runnable)     { double(template: template) }
  let(:offering)     { double(runnable: runnable, id: 23) }
  let(:report_learner) { double('last_run=' => true, update_fields: true) }
  let(:learner)      { double(offering: offering, report_learner: report_learner) }
  let(:event)        { double() }
  before(:each) do
    allow(Portal::Learner).to receive_messages(:find => learner)
    allow(learner).to receive_messages(:update_report_model_cache => true)
  end

  subject { Dataservice::V1::ProcessExternalActivityDataJob.new(23,json_content, Time.now())}

  describe "#perform" do
    describe "without lara_start" do
      let(:json_content) do
        {
          answers: [
          ]
        }.to_json
      end

      it "should build a LearnerProcessingEvent with a nil lara_start" do
        expect(LearnerProcessingEvent).to receive(:build_proccesing_event)
          .with(learner, nil, an_instance_of(Time), an_instance_of(Time), 0) {
            event
          }
        expect(event).to receive(:save)
        subject.perform
      end
    end

    describe "with lara_start" do
      let(:lara_start) { DateTime.new(1976,2,23) }
      let(:json_content) do
        {
          lara_start: lara_start.to_s,
          answers: [
          ]
        }.to_json
      end

      it "the create a LearnerProcessingEvent with lara_start" do
        expect(LearnerProcessingEvent).to receive(:build_proccesing_event)
          .with(learner, lara_start, an_instance_of(Time), an_instance_of(Time), 0) {
            event
          }
        expect(event).to receive(:save)
        subject.perform
      end
    end

  end


  # TODO: auto-generated
  describe '#lara_start' do
    it 'lara_start' do
      _learner = Portal::Learner.new
      _content = double('_content')
      _portal_start = double('_portal_start')
      process_external_activity_data_job = described_class.new(_learner, _content, _portal_start)
      result = process_external_activity_data_job.lara_start

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#lara_end' do
    it 'lara_end' do
      _learner = Portal::Learner.new
      _content = double('_content')
      _portal_start = double('_portal_start')
      process_external_activity_data_job = described_class.new(_learner, _content, _portal_start)
      result = process_external_activity_data_job.lara_end

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#perform' do
    xit 'perform' do
      _learner = Portal::Learner.new
      _content = double('_content')
      _portal_start = double('_portal_start')
      process_external_activity_data_job = described_class.new(_learner, _content, _portal_start)
      result = process_external_activity_data_job.perform

      expect(result).not_to be_nil
    end
  end


end
