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

  describe '#show?' do
    before(:each) do
      @teacher1 = FactoryBot.create(:portal_teacher)
      @teacher2 = FactoryBot.create(:portal_teacher)

      @runnable1 = FactoryBot.create(:external_activity)
      @runnable2 = FactoryBot.create(:external_activity)

      @offering1 = FactoryBot.create(:portal_offering, {clazz: @teacher1.clazzes[0], runnable: @runnable1})
      @offering2 = FactoryBot.create(:portal_offering, {clazz: @teacher2.clazzes[0], runnable: @runnable2})

      @student1 = FactoryBot.create(:full_portal_student)
      @student2 = FactoryBot.create(:full_portal_student)

      @teacher1.clazzes[0].students = [@student1]
      @teacher1.clazzes[0].save!

      @teacher2.clazzes[0].students = [@student2]
      @teacher2.clazzes[0].save!
    end

    describe 'for admins' do
      let(:admin) { FactoryBot.generate(:admin_user) }
      let(:policy) { described_class.new(admin, @offering1) }

      it 'should allow access' do
        expect(policy.show?).to be true
      end
    end

    describe 'for teachers' do
      describe 'of the class' do
        let(:policy) { described_class.new(@teacher1.user, @offering1) }

        it 'should allow access' do
          expect(policy.show?).to be true
        end
      end

      describe 'of other classes' do
        let(:policy) { described_class.new(@teacher2.user, @offering1) }

        it 'should not allow access' do
          expect(policy.show?).to be false
        end
      end
    end

    describe 'for students' do
      describe 'of the class' do
        let(:policy) { described_class.new(@student1.user, @offering1) }

        it 'should allow access when the offering is unlocked' do
          expect(policy.show?).to be true
        end

        describe 'when the offering is locked but the student is unlocked' do
          let(:user_offering_metadata) {
            FactoryBot.create(:user_offering_metadata, user: @student1.user, offering: @offering1, active: true, locked: false)
          }

          before(:each) do
            @offering1.locked = true
            @offering1.save!
          end

          it 'should allow access' do
            # ensure the offering metadata is created for the student to unlock the offering for the student
            user_offering_metadata
            expect(policy.show?).to be true
          end
        end

        describe 'when the offering is unlocked but the student is locked' do
          let(:user_offering_metadata) {
            FactoryBot.create(:user_offering_metadata, user: @student1.user, offering: @offering1, active: true, locked: true)
          }

          it 'should not allow access' do
            # ensure the offering metadata is created for the student to lock the offering for the student
            user_offering_metadata
            expect(policy.show?).to be false
          end
        end

        describe 'when the offering is locked but the show_feedback param is present' do
          # NOTE: instead of the user being passed in the context, we pass in an OpenStruct with the user and params
          # so that we can test the show_feedback param.  This is handled in ApplicationPolicy#initialize.
          let(:policy) { described_class.new(OpenStruct.new(user: @student1.user, params: { show_feedback: true }), @offering1) }

          before(:each) do
            @offering1.locked = true
            @offering1.save!
          end

          it 'should allow access' do
            expect(policy.show?).to be true
          end
        end
      end

      describe 'of other classes' do
        let(:policy) { described_class.new(@student2.user, @offering1) }

        it 'should not allow access' do
          expect(policy.show?).to be false
        end
      end
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

  describe '#update_student_metadata? (forwarded student)' do
    let(:teacher) { FactoryBot.create(:portal_teacher) }
    let(:student) { FactoryBot.create(:full_portal_student) }
    let(:clazz)   { FactoryBot.create(:portal_clazz, teachers: [teacher], students: [student]) }
    let(:origin_offering)     { FactoryBot.create(:portal_offering, clazz: clazz) }
    let(:non_origin_offering) { FactoryBot.create(:portal_offering, clazz: clazz) }
    let(:other_clazz)    { FactoryBot.create(:portal_clazz, teachers: [teacher]) }
    let(:other_offering) { FactoryBot.create(:portal_offering, clazz: other_clazz) }
    let(:mapped_user) { FactoryBot.create(:user) }
    let(:client)     { Admin::OidcClient.create!(name: 'C', sub: 'off-sub', user: mapped_user, capabilities: ['update_offering_state']) }
    let(:no_cap)     { Admin::OidcClient.create!(name: 'NC', sub: 'off-sub-nc', user: mapped_user, capabilities: []) }
    let(:acting_user) { student.user }

    def forwarded_context(user, offering, klass, params, oidc_client)
      env = {
        'portal.auth_client_id'     => oidc_client.id,
        'portal.forwarded_student'  => true,
        'portal.origin_offering_id' => offering.id,
        'portal.origin_class_hash'  => klass.class_hash
      }
      OpenStruct.new(user: user, original_user: user, request: OpenStruct.new(env: env), params: params)
    end

    def policy_for(record, params, oidc_client = client, user = acting_user)
      described_class.new(forwarded_context(user, origin_offering, clazz, params, oidc_client), record)
    end

    it 'allows locking the origin offering with update_offering_state' do
      expect(policy_for(origin_offering, { user_id: acting_user.id, locked: true }).update_student_metadata?).to be true
    end

    it 'denies without the capability' do
      expect(policy_for(origin_offering, { user_id: acting_user.id, locked: true }, no_cap).update_student_metadata?).to be false
    end

    it 'denies when the target user_id is not the acting student' do
      expect(policy_for(origin_offering, { user_id: mapped_user.id, locked: true }).update_student_metadata?).to be false
    end

    it 'still allows the teacher/admin path for a non-forwarded request' do
      expect(described_class.new(teacher.user, origin_offering).update_student_metadata?).to be true
    end

    it 'allows opening a non-origin enrolled offering (unlock / make visible)' do
      expect(policy_for(non_origin_offering, { user_id: acting_user.id, locked: false }).update_student_metadata?).to be true
      expect(policy_for(non_origin_offering, { user_id: acting_user.id, active: true }).update_student_metadata?).to be true
    end

    it 'denies locking or hiding a non-origin offering (string and JSON booleans)' do
      ['true', true].each do |v|
        expect(policy_for(non_origin_offering, { user_id: acting_user.id, locked: v }).update_student_metadata?).to be false
      end
      ['false', false].each do |v|
        expect(policy_for(non_origin_offering, { user_id: acting_user.id, active: v }).update_student_metadata?).to be false
      end
    end

    it 'allows the same lock/hide writes on the origin offering' do
      expect(policy_for(origin_offering, { user_id: acting_user.id, locked: true }).update_student_metadata?).to be true
      expect(policy_for(origin_offering, { user_id: acting_user.id, active: false }).update_student_metadata?).to be true
    end

    it 'denies a non-origin offering in a class the student is not in' do
      expect(policy_for(other_offering, { user_id: acting_user.id, locked: false }).update_student_metadata?).to be false
    end

    it 'stays student-scoped even when the acting user is also an admin' do
      acting_user.add_role('admin')
      expect(policy_for(non_origin_offering, { user_id: acting_user.id, locked: true }).update_student_metadata?).to be false
    end

    it 'denies a non-origin write with only user_id and no active/locked key' do
      expect(policy_for(non_origin_offering, { user_id: acting_user.id }).update_student_metadata?).to be false
    end

    it 'does not grant the forwarded branch through the bare update?' do
      expect(policy_for(origin_offering, { user_id: acting_user.id, locked: true }).update?).to be false
    end
  end

end
