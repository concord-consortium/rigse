require 'spec_helper'

describe Portal::ClazzMailer do
  let(:project) { FactoryGirl.create(:project) }

  let(:cohort) {
    FactoryGirl.create(:admin_cohort, email_notifications_enabled: true, project: project)
  }

  let(:teacher) {
    teacher = FactoryGirl.create(:portal_teacher)
    teacher.cohorts << cohort
    teacher
  }

  let(:user) {
    if teacher.nil?
      FactoryGirl.create(:user)
    else
      teacher.user.update_attributes(first_name: "Cohort", last_name: "Teacher")
      teacher.user
    end
  }

  let(:clazz) { FactoryGirl.create(:portal_clazz, :name => "Test Class") }
  before(:each) do
    @project_admin = FactoryGirl.create(:user, :first_name => "Project", :last_name => "Manager")
    @project_admin.add_role_for_project('admin', project)
  end

  describe "clazz_creation_notification" do
    subject { Portal::ClazzMailer.clazz_creation_notification(user, clazz) }

    context "when teacher is in a cohort" do
      it "sends a notification email to project admins" do
        expect(subject).to_not be_a(ActionMailer::Base::NullMail)
        expect(subject.Subject.value).to include("New class created by Cohort Teacher")
      end
    end
    context "when teacher is not in a cohort" do
      let(:teacher) { FactoryGirl.create(:portal_teacher) }
      it "does not send a notification email" do
        expect(subject).to be_a(ActionMailer::Base::NullMail)
      end
    end
    context "when teacher is in a cohort without a project" do
      let(:cohort) { FactoryGirl.create(:admin_cohort, email_notifications_enabled: true) }
      it "does not send a notification email" do
        expect(subject).to be_a(ActionMailer::Base::NullMail)
      end
    end
    context "when user is nil" do
      let(:user) { nil }
      it "does not send a notification email" do
        expect(subject).to be_a(ActionMailer::Base::NullMail)
      end
    end
    context "when user.portal_teacher is nil" do
      let(:teacher) { nil }
      it "does not send a notification email" do
        expect(subject).to be_a(ActionMailer::Base::NullMail)
      end
    end
    context "when teacher's cohort does not have notifications enabled" do
      let(:cohort) {
        FactoryGirl.create(:admin_cohort, email_notifications_enabled: false, project: project)
      }

      it "does not send a notification email" do
        expect(subject).to be_a(ActionMailer::Base::NullMail)
      end
    end
    context "when teacher's cohort has multiple admins" do
      before(:each) do
        second_admin = FactoryGirl.create(:user, :first_name => "Second", :last_name => "Manager")
        second_admin.add_role_for_project('admin', project)
      end
      it "sends a notification email to project admins" do
        expect(subject).to_not be_a(ActionMailer::Base::NullMail)
        expect(subject.To.value.join).to include("Project Manager")
        expect(subject.To.value.join).to include("Second Manager")
      end
    end
    context "when teacher is in two cohorts" do
      before(:each) do
        project2 = FactoryGirl.create(:project)
        cohort2 = FactoryGirl.create(:admin_cohort, email_notifications_enabled: true, project: project2)
        teacher.cohorts << cohort2
        second_admin = FactoryGirl.create(:user, :first_name => "Second", :last_name => "Manager")
        second_admin.add_role_for_project('admin', project2)
      end
      it "sends a notification email to both project admins" do
        expect(subject).to_not be_a(ActionMailer::Base::NullMail)
        expect(subject.To.value.join).to include("Project Manager")
        expect(subject.To.value.join).to include("Second Manager")
      end
    end
  end

  describe "clazz_assignment_notification" do
    subject { Portal::ClazzMailer.clazz_assignment_notification(user, clazz, "Activity 1") }
    context "when a teacher is in a cohort" do
      it "sends a notification email to project admins" do
        expect(subject).to_not be_a(ActionMailer::Base::NullMail)
        expect(subject.Subject.value).to include("Update: New assignment added by Cohort Teacher")
      end
    end

    context "when user is nil" do
      let(:user) { nil }
      it "does not send a notification email" do
        expect(subject).to be_a(ActionMailer::Base::NullMail)
      end
    end
    context "when user.portal_teacher is nil" do
      let(:teacher) { nil }
      it "does not send a notification email" do
        expect(subject).to be_a(ActionMailer::Base::NullMail)
      end
    end

  end

end
