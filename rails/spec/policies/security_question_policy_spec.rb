# frozen_string_literal: false

require 'spec_helper'

RSpec.describe SecurityQuestionPolicy do

  describe 'for a teacher preview student account and a normal student' do
    let(:teacher)        { FactoryBot.create(:portal_teacher) }
    let(:learner_user)   { teacher.find_or_create_teacher_preview_student! }
    let(:student_user)   { FactoryBot.create(:full_portal_student).user }

    it 'refuses the teacher preview student account' do
      policy = described_class.new(learner_user, SecurityQuestion)
      expect(policy.edit?).to be false
      expect(policy.update?).to be false
    end

    it 'still allows a normal student' do
      policy = described_class.new(student_user, SecurityQuestion)
      expect(policy.edit?).to be true
      expect(policy.update?).to be true
    end
  end

  # TODO: auto-generated
  describe '#edit?' do
    it 'edit?' do
      security_question_policy = described_class.new(nil, nil)
      result = security_question_policy.edit?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#update?' do
    it 'update?' do
      security_question_policy = described_class.new(nil, nil)
      result = security_question_policy.update?

      expect(result).to be_nil
    end
  end

end
