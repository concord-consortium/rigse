require 'spec_helper'

include ReportLearnerSpecHelper # defines : saveable_for : answers_for : add_answer : stub_all_reportables

describe Report::Learner::Selector do

  # assign the student permission_form_b to complicate the tests
  before(:each) {
    learner.student.permission_forms << students_p_forms
  }

  let(:current_user)        { FactoryBot.generate(:admin_user) }
  let(:project_a)           { FactoryBot.create(:admin_project, name: "project-a") }
  let(:permission_params_a) { { name: "a", project: project_a } }
  let(:permission_form_a)   { FactoryBot.create(:permission_form, permission_params_a) }
  let(:permission_params_b) { { name: "b" } }
  let(:permission_form_b)   { FactoryBot.create(:permission_form, permission_params_b) }
  let(:learner)             { FactoryBot.create(:full_portal_learner) }
  let(:report_learner)      { learner.report_learner                   }
  let(:selector)            { Report::Learner::Selector.new(selector_opts, current_user )   }
  let(:selector_opts)       { {} }
  let(:students_p_forms)    { [] }
  let(:runnable)            { FactoryBot.create(:external_activity, {
                              :name      => "Some Activity",
                              :url       => "http://example.com",
                              :save_path => "/path/to/save",
                            } )  }

  before(:each) do
    es_response = {
          "hits" => {
            "hits" => [
              {
                "_id" => report_learner.id,
                "_source" => {
                  "runnable_type_and_id" => "externalactivity_#{runnable.id}"
                }
              }
            ]
          }
        }.to_json
    WebMock.stub_request(:post, /report_learners\/_search$/).
      to_return { |request| {
        headers: {'Content-Type'=>'application/json'},
        body: es_response
      }
    }
  end

  describe "when processing a predefined ES response" do
    it "should return the learner when it finds a learner id" do
      expect(selector.learners).to include report_learner
    end
    it "should return the runnable when it finds a runnable type and id" do
      expect(selector.runnables_to_report_on).to include runnable
    end
  end


  # TODO: auto-generated
  describe '#runnables_to_report_on' do
    it 'runnables_to_report_on' do
      options = {}
      current_visitor = User.new
      selector = described_class.new(options, current_visitor)
      result = selector.runnables_to_report_on

      expect(result).not_to be_nil
    end
  end


end
