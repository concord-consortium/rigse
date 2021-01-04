require File.expand_path('../../../spec_helper', __FILE__)

describe Dataservice::ProcessExternalActivityDataJob do
  let(:template)     { double({open_responses: [], multiple_choices: [], image_questions: [], iframes: []}) }
  let(:runnable)     { double(template: template) }
  let(:offering)     { double(runnable: runnable, id: 23) }
  let(:report_learner) { double('last_run=' => true, update_fields: true)}
  let(:learner)      { double(offering: offering, report_learner: report_learner) }
  let(:good_content) do
    [
      {
        type: "open_response",
        question_id: 1
      },
      {
        type: "multiple_choice",
        question_id: 2
      },
      {
        type: "image_question",
        question_id: 3
      },
      {
        type: "external_link",
        question_type: "iframe interactive",
        question_id: 4
      },
      {
        type: "interactive",
        question_id: 5
      }
    ].to_json
  end

  let(:bad_content) do
    [
      {
        type: "fruitloops",
        question_id: 4
      },{
        type: "multiple_choice",
        question_id: 2
      },
    ].to_json
  end

  let(:json_content) { good_content }

  subject { Dataservice::ProcessExternalActivityDataJob.new(23,json_content)}
  before(:each) do
    allow(Portal::Learner).to receive_messages(:find => learner)
    allow(subject).to receive(:internal_process_open_response)
    allow(subject).to receive(:internal_process_multiple_choice)
    allow(subject).to receive(:internal_process_image_question)
    allow(subject).to receive(:internal_process_external_link)
    allow(subject).to receive(:internal_process_interactive)
  end


  describe "#perform" do
    describe "with weird content" do
      let(:json_content) { bad_content }

      it "should record a name exception when performing" do
        expect(subject.content).to eq(bad_content)
        expect(Rails.logger).to receive :info
        expect(NewRelic::Agent).to receive :notice_error
        expect(subject).to receive :internal_process_multiple_choice
        subject.perform
      end
    end

    describe "with good content" do
      it "should not record any exceptions when performing" do
        expect(subject.content).to eq(good_content)
        expect(Rails.logger).not_to receive :info
        expect(NewRelic::Agent).not_to receive :notice_error
        expect(subject).to receive :internal_process_open_response
        expect(subject).to receive :internal_process_multiple_choice
        expect(subject).to receive :internal_process_image_question
        expect(subject).to receive :internal_process_external_link
        expect(subject).to receive :internal_process_interactive
        subject.perform
      end
    end
  end


  # TODO: auto-generated
  describe '#perform' do
    it 'perform' do
      _learner_id = 1
      _content = '1'
      process_external_activity_data_job = described_class.new(_learner_id, _content)
      result = process_external_activity_data_job.perform

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#internal_process_open_response' do
    it 'internal_process_open_response' do
      _learner_id = 1
      _content = '1'
      process_external_activity_data_job = described_class.new(_learner_id, _content)
      data = {}
      embeddable = FactoryBot.create(:open_response)
      result = process_external_activity_data_job.internal_process_open_response(data, embeddable)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#internal_process_multiple_choice' do
    it 'internal_process_multiple_choice' do
      _learner_id = 1
      _content = '1'
      process_external_activity_data_job = described_class.new(_learner_id, _content)
      data = { 'answer_ids' => [] }
      embeddable = FactoryBot.create(:open_response)

      result = process_external_activity_data_job.internal_process_multiple_choice(data, embeddable)

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#internal_process_image_question' do
    it 'internal_process_image_question' do
      _learner_id = 1
      _content = '1'
      process_external_activity_data_job = described_class.new(_learner_id, _content)
      data = {}
      embeddable = FactoryBot.create(:open_response)
      result = process_external_activity_data_job.internal_process_image_question(data, embeddable)

      expect(result).not_to be_nil
    end
  end

  describe '#internal_process_external_link' do
    it 'internal_process_external_link' do
      _learner_id = 1
      _content = '1'
      process_external_activity_data_job = described_class.new(_learner_id, _content)
      data = {}
      embeddable = FactoryBot.create(:open_response)
      result = process_external_activity_data_job.internal_process_external_link(data, embeddable)

      expect(result).not_to be_nil
    end
  end

  describe '#internal_process_interactive' do
    it 'internal_process_interactive' do
      _learner_id = 1
      _content = '1'
      process_external_activity_data_job = described_class.new(_learner_id, _content)
      data = {}
      embeddable = FactoryBot.create(:open_response)
      result = process_external_activity_data_job.internal_process_interactive(data, embeddable)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#id' do
    it 'id' do
      _learner_id = double('_learner_id')
      _content = double('_content')
      process_external_activity_data_job = described_class.new(_learner_id, _content)
      result = process_external_activity_data_job.id

      expect(result).to be_nil
    end
  end


end
