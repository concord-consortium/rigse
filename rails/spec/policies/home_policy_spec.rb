# frozen_string_literal: false

require 'spec_helper'

RSpec.describe HomePolicy do

  # TODO: auto-generated
  describe '#admin?' do
    it 'admin?' do
      home_policy = described_class.new(nil, nil)
      result = home_policy.admin?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#recent_activity?' do
    it 'recent_activity?' do
      home_policy = described_class.new(nil, nil)
      result = home_policy.recent_activity?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#authoring?' do
    it 'authoring?' do
      home_policy = described_class.new(nil, nil)
      result = home_policy.authoring?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#authoring_site_redirect?' do
    it 'authoring_site_redirect?' do
      home_policy = described_class.new(nil, nil)
      result = home_policy.authoring_site_redirect?

      expect(result).to be_nil
    end
  end

  describe '#my_classes?' do
    it 'allows a student' do
      student_user = FactoryBot.create(:full_portal_student).user
      expect(described_class.new(student_user, nil).my_classes?).to be true
    end

    it 'refuses a teacher' do
      teacher_user = FactoryBot.create(:portal_teacher).user
      expect(described_class.new(teacher_user, nil).my_classes?).to be false
    end

    it 'refuses an anonymous visitor' do
      expect(described_class.new(nil, nil).my_classes?).to be_falsey
    end
  end

  describe '#getting_started?' do
    let(:teacher) { FactoryBot.create(:portal_teacher) }

    it 'allows a teacher' do
      expect(described_class.new(teacher.user, nil).getting_started?).to be true
    end

    it 'allows an anonymous visitor' do
      expect(described_class.new(nil, nil).getting_started?).to be true
    end

    it 'refuses a teacher preview student account' do
      learner_user = teacher.find_or_create_teacher_preview_student!
      expect(described_class.new(learner_user, nil).getting_started?).to be false
    end

    it 'refuses a student' do
      student = FactoryBot.create(:full_portal_student)
      expect(described_class.new(student.user, nil).getting_started?).to be false
    end
  end

end
