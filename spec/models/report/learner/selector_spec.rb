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
      let(:students_p_forms) { [permission_form_a] }
      it "our student should have the required permission form" do
        expect(learner.student.permission_forms).to include permission_form_a
      end
      it "selector should filter the results and return our student" do
        expect(selector.learners).to include report_learner
      end
    end

    describe "when the student hasn't given us the permission form we are searching for" do
      it "the learner should not have our permission form" do
        expect(learner.student.permission_forms).not_to include permission_form_a
      end
      it "selector should return results without our student" do
         expect(selector.learners).not_to include report_learner
      end
    end

    # Ensure we only return one row per learner, even when
    # The student has multiple permission forms completed.
    describe "when searching for two permissions forms" do
      let(:selector_opts) {{ 'perm_form' => [permission_form_a.id, permission_form_b.id] }}
      describe "and the student has both of the forms completed" do
        let(:students_p_forms) { [permission_form_a, permission_form_b ]}
        it "the user should have both permission forms" do
          expect(learner.student.permission_forms).to include permission_form_b
          expect(learner.student.permission_forms).to include permission_form_a
        end
        it "selector should only return the one report_learner" do
          expect(selector.learners).to include report_learner
          expect(selector.learners.size).to eql(1)
        end
      end
    end

    # Ensure we report each learner for students with multiple
    # matching a given permission form selection.
    describe "when the student has multiple learners" do
      let(:other_learner) do
        FactoryGirl.create(:full_portal_learner, {:student => learner.student})
      end
      let(:other_report_learner) { other_learner.report_learner }
      describe "when searching for two permissions forms" do
        let(:selector_opts) {{ 'perm_form' => [permission_form_a.id, permission_form_b.id] }}

        describe "and the student has both of the forms completed" do
          let(:students_p_forms) {[permission_form_a, permission_form_b] }
          it "selector should still only return the one report_learner" do
            other_report_learner # creates the other learner
            expect(selector.learners).to include report_learner
            expect(selector.learners).to include other_report_learner
            expect(selector.learners.size).to eql(2)
          end
        end
      end
    end

  end
end
