require 'spec_helper'

include ReportLearnerSpecHelper # defines : saveable_for : answers_for : add_answer : stub_all_reportables

describe Report::Learner::Selector do

  # assign the student permission_form_b to complicate the tests …
  before(:each) {
    learner.student.permission_forms << permission_form_b
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

  describe "with no permission form filter selected" do
    it "should return one learner for our student" do
      expect(selector.learners).to include report_learner
    end
  end

  describe "when filtering based on permission forms" do
    let(:selector_opts)     {{ 'perm_form' => [permission_form_a.id] }}

    it "expect the selector to specify our permission form" do
      expect(selector.select_perm_form).to include permission_form_a
    end

    describe "when the student has the selected permission form (a)" do
      before(:each) {
        learner.student.permission_forms << permission_form_a
      }
      it "our student should have the required permission form" do
        expect(learner.student.permission_forms).to include permission_form_a
      end
      it "selector should filter the results and return our student" do
        expect(selector.learners).to include report_learner
      end
    end

    describe "when the student hasn't given us the permission form we are looking for" do
      it "the learner should not have our permission form" do
        expect(learner.student.permission_forms).not_to include permission_form_a
      end
      it "selector should return results without our student" do
        expect(selector.learners).not_to include report_learner
      end
    end
  end
end
