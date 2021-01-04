# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Portal::TeacherPolicy do

  let(:user)   { FactoryBot.create(:user) }
  let(:scope)  { Pundit.policy_scope!(user, Portal::Teacher) }

  describe "Scope" do
    before(:each) do
      @cohort1 = FactoryBot.create(:admin_cohort)
      @cohort2 = FactoryBot.create(:admin_cohort)

      @teacher1 = FactoryBot.create(:portal_teacher)
      @teacher2 = FactoryBot.create(:portal_teacher)
      @teacher3 = FactoryBot.create(:portal_teacher)

      @teacher1.cohorts << @cohort1
      @teacher2.cohorts << @cohort1
      @teacher3.cohorts << @cohort2
    end

    context 'normal user' do
      it 'does not allow access to any teachers' do
        expect(scope.to_a.length).to eq 0
      end
    end

    context 'teacher' do
      let(:user){ @teacher1.user }
      it 'should return their own teacher record' do
        # Even a teacher who is not a project admin should
        # have access to their own teacher record
        expect(scope.to_a).to include(@teacher1)
      end
      context 'is a project_admin for cohorts1' do
        before(:each) do
          @project = FactoryBot.create(:project)
          @project.cohorts << @cohort1
          user.add_role_for_project('admin', @project)
        end
        it 'should return teacher2 and teacher1 (both in chort1)' do
          # teacher1 (cohort 1) and teacher2 (cohort1)
          expect(scope.to_a).to include(@teacher1, @teacher2)
          expect(scope.to_a.length).to eq 2
        end
      end

      context 'is a project_admin for a different cohort (chort2)' do
        before(:each) do
          @project = FactoryBot.create(:project)
          @project.cohorts << @cohort2
          user.add_role_for_project('admin', @project)
        end
        it 'should return their own teacher record (in cohort1)' do
          # There is also a teacher in Cohort2 (not our cohort)
          expect(scope.to_a).to include(@teacher1, @teacher3)
          expect(scope.to_a.length).to eq 2
        end
      end

      context 'has visited a collection page' do
        before(:each) do
          @project1 = FactoryBot.create(:project)
          @project2 = FactoryBot.create(:project)
          @teacher1.record_project_view(@project1)
        end
        it 'allow access to own visited collection pages' do
          @teacher1.viewed_projects
          expect(scope.to_a).to include(@teacher1)
        end
        it 'allow updates to own visited collection pages' do
          @teacher1.record_project_view(@project2)
          expect(scope.to_a).to include(@teacher1)
        end
      end
    end

    context 'project researcher' do
      before(:each) do
        @project = FactoryBot.create(:project)
        @project.cohorts << @cohort1
        user.add_role_for_project('researcher', @project)
      end

      it 'allows access to project teachers' do
        expect(scope.to_a).to match_array([@teacher1, @teacher2])
      end
    end

    context 'project admin' do
      before(:each) do
        @project = FactoryBot.create(:project)
        @project.cohorts << @cohort2
        user.add_role_for_project('admin', @project)
      end

      it 'allows access to project teachers' do
        expect(scope.to_a).to match_array([@teacher3])
      end
    end

    context 'admin user' do
      let(:user) { FactoryBot.generate(:admin_user) }
      it 'allows access to all teachers' do
        expect(scope.to_a).to match_array([@teacher1, @teacher2, @teacher3])
      end
    end
  end

  # TODO: auto-generated
  describe '#show?' do
    it 'show?' do
      teacher_policy = described_class.new(nil, nil)
      result = teacher_policy.show?

      expect(result).to be_nil
    end
  end

end
