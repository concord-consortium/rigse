# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Portal::OfferingPolicy do

  let(:user) { FactoryBot.create(:user) }
  let(:scope) { Pundit.policy_scope!(user, Portal::Offering) }

  describe "Scope" do
    before(:each) do
      @project1 = FactoryBot.create(:project)
      @project2 = FactoryBot.create(:project)
      @project3 = FactoryBot.create(:project)

      @cohort1 = FactoryBot.create(:admin_cohort)
      @cohort2 = FactoryBot.create(:admin_cohort)
      @cohort3 = FactoryBot.create(:admin_cohort)

      @project1.cohorts << @cohort1
      @project2.cohorts << @cohort2
      @project3.cohorts << @cohort3

      @teacher1 = FactoryBot.create(:portal_teacher)
      @teacher2 = FactoryBot.create(:portal_teacher)
      @teacher3 = FactoryBot.create(:portal_teacher)

      @runnable1 = FactoryBot.create(:external_activity)
      @runnable2 = FactoryBot.create(:external_activity)
      @runnable3 = FactoryBot.create(:external_activity)

      @offering1 = FactoryBot.create(:portal_offering, {clazz: @teacher1.clazzes[0], runnable: @runnable1})
      @offering2 = FactoryBot.create(:portal_offering, {clazz: @teacher2.clazzes[0], runnable: @runnable2})
      @offering3 = FactoryBot.create(:portal_offering, {clazz: @teacher3.clazzes[0], runnable: @runnable3})

      @teacher1.cohorts << @cohort1
      @teacher2.cohorts << @cohort1
      @teacher3.cohorts << @cohort2
    end

    context 'normal user' do
      it 'does not allow access to any offerings' do
        expect(scope.to_a.length).to eq 0
      end
    end

    context 'project researcher' do
      before(:each) do
        user.add_role_for_project('researcher', @project1)
      end

      it 'allows access to project offerings' do
        expect(scope.to_a).to match_array([@offering1, @offering2])
      end
    end

    context 'project admin' do
      before(:each) do
        user.add_role_for_project('admin', @project2)
      end

      it 'allows access to project offerings' do
        expect(scope.to_a).to match_array([@offering3])
      end

    end

    context 'teacher' do
      let(:user) { @teacher1.user }
      it 'allows access to teacher offerings' do
        expect(scope.to_a).to match_array([@offering1])
      end
      context 'who is also a project admin' do
        before(:each) do
          # project3 is for @cohort3 and has no teachers in it.
          user.add_role_for_project('admin', @project3)
        end
        it 'allows access to teacher offerings' do
          # We still expect to see the teachers own offering here
          # Even though they are not an admin for @project1
          expect(scope.to_a).to match_array([@offering1])
        end
      end
    end

    context 'admin user' do
      let(:user) { FactoryBot.generate(:admin_user) }
      it 'allows access to all offerings' do
        expect(scope.to_a).to match_array([@offering1, @offering2, @offering3])
      end
    end
  end

  # TODO: auto-generated
  describe '#api_show?' do
    it 'api_show?' do
      offering_policy = described_class.new(nil, nil)
      result = offering_policy.api_show?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#api_index?' do
    it 'api_index?' do
      offering_policy = described_class.new(nil, nil)
      result = offering_policy.api_index?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#api_report?' do
    it 'api_report?' do
      offering_policy = described_class.new(nil, nil)
      result = offering_policy.api_report?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#show?' do
    it 'show?' do
      offering_policy = described_class.new(nil, nil)
      result = offering_policy.show?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#destroy?' do
    it 'destroy?' do
      offering_policy = described_class.new(nil, nil)
      result = offering_policy.destroy?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#activate?' do
    it 'activate?' do
      offering_policy = described_class.new(nil, nil)
      result = offering_policy.activate?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#deactivate?' do
    it 'deactivate?' do
      offering_policy = described_class.new(nil, nil)
      result = offering_policy.deactivate?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#update?' do
    it 'update?' do
      offering_policy = described_class.new(nil, nil)
      result = offering_policy.update?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#answers?' do
    it 'answers?' do
      offering_policy = described_class.new(nil, nil)
      result = offering_policy.answers?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#student_report?' do
    it 'student_report?' do
      offering_policy = described_class.new(nil, nil)
      result = offering_policy.student_report?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#report?' do
    it 'report?' do
      offering_policy = described_class.new(nil, nil)
      result = offering_policy.report?

      expect(result).to be_nil
    end
  end

  describe '#external_report?' do
    let(:report) {
      FactoryBot.create(:external_report)
    }
    let(:context) {
      double(
        user: user,
        original_user: nil,
        request: nil,
        params: {
          report_id: report.id
          })
    }
    let (:offering) {
      FactoryBot.create(:portal_offering,
        runnable: FactoryBot.create(:external_activity))
    }

    subject {
      # make sure the report of the offering is our report
      offering.runnable.external_reports << report
      offering_policy = described_class.new(context, offering)
      offering_policy.external_report?
    }
    context 'user is not part of clazz or admin' do
      it { is_expected.to be_falsey }
    end
    context 'user is a teacher of offering clazz' do
      let(:user) {
        teacher = FactoryBot.create(:portal_teacher, :clazzes => [offering.clazz])
        teacher.user
      }
      it { is_expected.to be_truthy }
    end
    context 'user is a teacher of a different clazz' do
      let(:user) {
        clazz = FactoryBot.create(:portal_clazz)
        teacher = FactoryBot.create(:portal_teacher, :clazzes => [clazz])
        teacher.user
      }
      it { is_expected.to be_falsey }
    end
    context 'user is a student in the clazz' do
      let(:user) {
        student = FactoryBot.create(:full_portal_student, :clazzes => [offering.clazz])
        student.user
      }
      context 'report is not allowed for students' do
        it { is_expected.to be_falsey }
      end
      context 'report is allowed for students' do
        let(:report) {
          FactoryBot.create(:external_report, allowed_for_students: true)
        }
        it { is_expected.to be_truthy }
      end
    end
    context 'user is a researcher, but not for this clazz' do
      before(:each) {
        context.params[:researcher] = true
      }
      let(:user) { FactoryBot.generate(:researcher_user) }
      it { is_expected.to be_falsy }
    end
    context 'user is a researcher for this clazz and researcher=true param is provided' do
      let(:project) { FactoryBot.create(:project, cohorts: [cohort]) }
      let(:cohort)  { FactoryBot.create(:admin_cohort) }
      let(:teacher) { FactoryBot.create(:portal_teacher, clazzes: [offering.clazz], cohorts: [cohort]) }
      before(:each) {
        teacher # make sure teacher is actually created
        context.params[:researcher] = true
      }
      let(:user) {
        researcher = FactoryBot.generate(:researcher_user)
        researcher.researcher_for_projects << project
        researcher
      }

      it { is_expected.to be_truthy }
    end
    context 'user is a researcher for this clazz but researcher=true param is not provided' do
      let(:project) { FactoryBot.create(:project, cohorts: [cohort]) }
      let(:cohort)  { FactoryBot.create(:admin_cohort) }
      let(:teacher) { FactoryBot.create(:portal_teacher, clazzes: [offering.clazz], cohorts: [cohort]) }
      before(:each) {
        teacher # make sure teacher is actually created
      }
      let(:user) {
        researcher = FactoryBot.generate(:researcher_user)
        researcher.researcher_for_projects << project
        researcher
      }

      it { is_expected.to be_falsy }
    end
  end

  # TODO: auto-generated
  describe '#offering_collapsed_status?' do
    it 'offering_collapsed_status?' do
      offering_policy = described_class.new(nil, nil)
      result = offering_policy.offering_collapsed_status?

      expect(result).to be_nil
    end
  end

end
