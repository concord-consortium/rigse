require 'spec_helper'

include ReportLearnerSpecHelper # defines : saveable_for : answers_for : add_answer : stub_all_reportables

describe Report::Learner::Selector do

  # assign the student permission_form_b to complicate the tests …
  before(:each) {
    learner.student.permission_forms << students_p_forms
  }

  let(:current_user)        { Factory.next(:admin_user) }
  let(:project_a)           { FactoryGirl.create(:admin_project, name: "project-a") }
  let(:permission_params_a) { { name: "a", project: project_a } }
  let(:permission_form_a)   { FactoryGirl.create(:permission_form, permission_params_a) }
  let(:permission_params_b) { { name: "b" } }
  let(:permission_form_b)   { FactoryGirl.create(:permission_form, permission_params_b) }
  let(:learner)             { FactoryGirl.create(:full_portal_learner) }
  let(:report_learner)      { learner.report_learner                   }
  let(:selector)            { Report::Learner::Selector.new(selector_opts, current_user )   }
  let(:selector_opts)       { {} }
  let(:students_p_forms)    { [] }
  let(:runnable)            { Factory(:external_activity, {
                              :name      => "Some Activity",
                              :url       => "http://example.com",
                              :save_path => "/path/to/save",
                            } )  }

  before (:each) do
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
end
