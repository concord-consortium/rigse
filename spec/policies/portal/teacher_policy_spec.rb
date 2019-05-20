# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Portal::TeacherPolicy do

  let(:user) { FactoryBot.create(:user) }
  let(:scope) { Pundit.policy_scope!(user, Portal::Teacher) }

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
