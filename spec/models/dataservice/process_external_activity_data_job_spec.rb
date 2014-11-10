require File.expand_path('../../../spec_helper', __FILE__)

describe Dataservice::ProcessExternalActivityDataJob do
  let(:template)     { mock({open_responses: [], multiple_choices: [], image_questions: [], iframes: []}) }
  let(:runnable)     { mock(template: template) }
  let(:offering)     { mock(runnable: runnable, id: 23) }
  let(:report_learner) { mock('last_run=' => true, update_fields: true)}
  let(:learner)      { mock(offering: offering, report_learner: report_learner) }
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
    Portal::Learner.stub!(:find => learner)
    subject.stub!(:internal_process_open_response)
    subject.stub!(:internal_process_multiple_choice)
    subject.stub!(:internal_process_image_question)
    subject.stub!(:internal_process_external_link)
  end


  describe "#perform" do
    describe "with weird content" do
      let(:json_content) { bad_content }

      it "should record a name exception when performing" do
        subject.content.should == bad_content
        Rails.logger.should_receive :info
        NewRelic::Agent.should_receive :notice_error
        subject.should_receive :internal_process_multiple_choice
        subject.perform
      end
    end

    describe "with good content" do
      it "should not record any exceptions when performing" do
        subject.content.should == good_content
        Rails.logger.should_not_receive :info
        NewRelic::Agent.should_not_receive :notice_error
        subject.should_receive :internal_process_open_response
        subject.should_receive :internal_process_multiple_choice
        subject.should_receive :internal_process_image_question
        subject.should_receive :internal_process_external_link
        subject.perform
      end
    end
  end
end
