require 'spec_helper'

describe Portal::ClazzMailer do
  let(:projects) { 5.times.map { |i|  FactoryGirl.create(:project, name: "project_#{i}")}  }
  before(:each) do

    @cohort = Factory.create(:admin_cohort, {email_notifications_enabled: true})
    @project = Factory.create(:project)
    @project.cohorts << @cohort
    projects << @project

    @project_admin = Factory.create(:user, :first_name => "Project", :last_name => "Manager")
    @project_admin.set_role_for_projects('admin', projects, [@project.id])

    @teacher = Factory.create(:portal_teacher, :user => Factory.create(:user, :first_name => "Cohort", :last_name => "Teacher"))
    @teacher.cohorts << @cohort

    @clazz = FactoryGirl.create(:portal_clazz, :name => "Test Class")

  end

  describe "clazz_creation_notification" do
    context "when a class is created by a teacher in a cohort" do
      it "sends a notification email to project admins" do
        result = Portal::ClazzMailer.clazz_creation_notification(@teacher, @clazz)
        expect(result.Subject.value).to include("New class created by Cohort Teacher")
      end
    end
  end

  describe "clazz_assignment_notification" do
    context "when a teacher in a cohort assigns a resource to a class" do
      it "sends a notification email to project admins" do
        result = Portal::ClazzMailer.clazz_assignment_notification(@teacher, @clazz, "Activity 1")
        expect(result.Subject.value).to include("Update: New assignment added by Cohort Teacher")
      end
    end
  end

  def create_clazz(options = {})
    post :create, :clazz => { :name => 'Test Class' }.merge(options)
  end

end
