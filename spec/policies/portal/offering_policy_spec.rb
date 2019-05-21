# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Portal::OfferingPolicy do

  let(:user) { FactoryBot.create(:user) }
  let(:scope) { Pundit.policy_scope!(user, Portal::Offering) }

  describe "Scope" do
    before(:each) do
      @cohort1 = FactoryBot.create(:admin_cohort)
      @cohort2 = FactoryBot.create(:admin_cohort)

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
        @project = FactoryBot.create(:project)
        @project.cohorts << @cohort1
        user.add_role_for_project('researcher', @project)
      end

      it 'allows access to project offerings' do
        expect(scope.to_a).to match_array([@offering1, @offering2])
      end
    end

    context 'project admin' do
      before(:each) do
        @project = FactoryBot.create(:project)
        @project.cohorts << @cohort2
        user.add_role_for_project('admin', @project)
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

  # TODO: auto-generated
  describe '#external_report?' do
    it 'external_report?' do
      offering_policy = described_class.new(nil, nil)
      result = offering_policy.external_report?

      expect(result).to be_nil
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
