# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Admin::CohortPolicy do
  before(:each) do
    @cohort1 = FactoryBot.create(:admin_cohort)
    @cohort2 = FactoryBot.create(:admin_cohort)
    @cohort3 = FactoryBot.create(:admin_cohort)
  end

  let(:user) { FactoryBot.create(:user) }
  let(:scope) { Pundit.policy_scope!(user, Admin::Cohort) }
  let(:cohort_stubs) { {project: 'project' } }
  let(:proj_user) { FactoryBot.create(:user) }
  let(:cohort) { double('cohort', cohort_stubs) }

  describe "Scope" do
    context 'normal user' do
      it 'does not allow access to any cohorts' do
        expect(scope.to_a.length).to eq 0
      end
    end

    context 'project researcher' do
      before(:each) do
        @project = FactoryBot.create(:project)
        @project.cohorts << @cohort1
        user.add_role_for_project('researcher', @project)
      end

      it 'allows access to project cohorts' do
        expect(scope.to_a).to match_array([@cohort1])
      end
    end

    context 'project admin' do
      before(:each) do
        @project = FactoryBot.create(:project)
        @project.cohorts << @cohort1
        user.add_role_for_project('admin', @project)
      end

      it 'allows access to project cohorts' do
        expect(scope.to_a).to match_array([@cohort1])
      end
    end

    context 'admin user' do
      let(:user) { FactoryBot.generate(:admin_user) }
      it 'allows access to all cohorts' do
        expect(scope.to_a).to match_array([@cohort1, @cohort2, @cohort3])
      end
    end
  end

  describe 'create' do
    context 'as project admin' do
      before(:each) do
        allow(proj_user).to receive(:is_project_admin?).and_return(true)
      end

      it 'should allow create' do
        expect(Admin::CohortPolicy.new(proj_user, cohort)).to permit(:create)
      end
    end

    context 'not as project admin' do
      before(:each) do
        allow(proj_user).to receive(:is_project_admin?).and_return(false)
      end
      it 'should allow create' do
        expect(Admin::CohortPolicy.new(proj_user, cohort)).to_not permit(:create)
      end
    end
  end

  describe 'destroy' do
    context 'as project admin' do
      before(:each) do
        allow(proj_user).to receive(:is_project_admin?).and_return(true)
      end

      it 'should allow destroy' do
        expect(Admin::CohortPolicy.new(proj_user, cohort)).to permit(:destroy)
      end
    end

    context 'not as project admin' do
      before(:each) do
        allow(proj_user).to receive(:is_project_admin?).and_return(false)
      end

      it 'should not allow create' do
        expect(Admin::CohortPolicy.new(proj_user, cohort)).to_not permit(:create)
      end

      it 'should not allow destroy' do
        expect(Admin::CohortPolicy.new(proj_user, cohort)).to_not permit(:destroy)
      end
    end
  end
end
