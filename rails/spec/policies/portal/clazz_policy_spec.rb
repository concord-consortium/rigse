# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Portal::ClazzPolicy do
  let(:user) { FactoryBot.create(:user) }
  let(:scope) { Pundit.policy_scope!(user, Portal::Clazz) }

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

      @teacher1.cohorts << @cohort1
      @teacher2.cohorts << @cohort1
      @teacher3.cohorts << @cohort2

      @clazz1 = @teacher1.clazzes[0]
      @clazz2 = @teacher2.clazzes[0]
      @clazz3 = @teacher3.clazzes[0]
    end

    context 'normal user' do
      it 'does not allow access to any classes' do
        expect(scope.to_a.length).to eq 0
      end
    end

    context 'project researcher' do
      before(:each) do
        user.add_role_for_project('researcher', @project1)
      end

      it 'allows access to project classes' do
        expect(scope.to_a).to match_array([@clazz1, @clazz2])
      end
    end

    context 'project admin' do
      before(:each) do
        user.add_role_for_project('admin', @project2)
      end

      it 'allows access to project classes' do
        expect(scope.to_a).to match_array([@clazz3])
      end

    end

    context 'teacher' do
      let(:user) { @teacher1.user }
      it 'allows access to teacher classes' do
        expect(scope.to_a).to match_array([@clazz1])
      end
      context 'who is also a project admin' do
        before(:each) do
          # project3 is for @cohort3 and has no teachers in it.
          user.add_role_for_project('admin', @project3)
        end
        it 'allows access to teacher classes' do
          # We still expect to see the teachers own classes here
          # Even though they are not an admin for @project1
          expect(scope.to_a).to match_array([@clazz1])
        end
      end
    end

    context 'admin user' do
      let(:user) { FactoryBot.generate(:admin_user) }
      it 'allows access to all classes' do
        expect(scope.to_a).to match_array([@clazz1, @clazz2, @clazz3])
      end
    end
  end

  describe '#add_to_class? (forwarded student)' do
    let(:teacher)  { FactoryBot.create(:portal_teacher) }
    let(:student)  { FactoryBot.create(:full_portal_student) }
    let(:other_student) { FactoryBot.create(:full_portal_student) }
    let(:origin_clazz)   { FactoryBot.create(:portal_clazz, teachers: [teacher], students: [student]) }
    let(:origin_offering) { FactoryBot.create(:portal_offering, clazz: origin_clazz) }
    let(:shared_class)   { FactoryBot.create(:portal_clazz, teachers: [teacher]) }
    let(:unshared_class) { FactoryBot.create(:portal_clazz, teachers: [FactoryBot.create(:portal_teacher)]) }
    let(:archived_shared_class) { FactoryBot.create(:portal_clazz, teachers: [teacher], is_archived: true) }
    let(:mapped_user) { FactoryBot.create(:user) }
    let(:client)  { Admin::OidcClient.create!(name: 'C', sub: 'clz-sub', user: mapped_user, capabilities: ['enroll_student']) }
    let(:no_cap)  { Admin::OidcClient.create!(name: 'NC', sub: 'clz-sub-nc', user: mapped_user, capabilities: []) }
    let(:acting_user) { student.user }

    def enroll_context(params, oidc_client, user)
      env = {
        'portal.auth_client_id'     => oidc_client.id,
        'portal.forwarded_student'  => true,
        'portal.origin_offering_id' => origin_offering.id,
        'portal.origin_class_hash'  => origin_clazz.class_hash
      }
      OpenStruct.new(user: user, original_user: user, request: OpenStruct.new(env: env), params: params)
    end

    def policy_for(record, params, oidc_client = client, user = acting_user)
      described_class.new(enroll_context(params, oidc_client, user), record)
    end

    it 'allows enrolling the acting student into a shared-teacher class' do
      expect(policy_for(shared_class, { user_id: acting_user.id }).add_to_class?).to be true
    end

    it 'denies a target class with no shared teacher' do
      expect(policy_for(unshared_class, { user_id: acting_user.id }).add_to_class?).to be false
    end

    it 'denies an archived target class' do
      expect(policy_for(archived_shared_class, { user_id: acting_user.id }).add_to_class?).to be false
    end

    it 'denies without the enroll_student capability' do
      expect(policy_for(shared_class, { user_id: acting_user.id }, no_cap).add_to_class?).to be false
    end

    it 'stays student-scoped even when the acting user is also an admin' do
      acting_user.add_role('admin')
      expect(policy_for(shared_class, { user_id: other_student.user.id }).add_to_class?).to be false
    end

    it 'denies a mismatched user_id' do
      expect(policy_for(shared_class, { user_id: other_student.user.id }).add_to_class?).to be false
    end

    it 'denies a mismatched student_id' do
      expect(policy_for(shared_class, { student_id: other_student.id }).add_to_class?).to be false
    end

    it 'denies the mixed case: self user_id with another student_id' do
      expect(policy_for(shared_class, { user_id: acting_user.id, student_id: other_student.id }).add_to_class?).to be false
    end

    it 'allows the consistent both-present case (user_id and student_id both the acting student)' do
      expect(policy_for(shared_class, { user_id: acting_user.id, student_id: student.id }).add_to_class?).to be true
    end

    it 'does not grant the forwarded branch through the bare update_roster?' do
      expect(policy_for(shared_class, { user_id: acting_user.id }).update_roster?).to be false
    end
  end
end
