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
end
