# frozen_string_literal: false

require 'spec_helper'


RSpec.describe Saveable::MultipleChoiceAnswer, type: :model do



  # TODO: auto-generated
  describe '#answer' do
    it 'answer' do
      multiple_choice_answer = described_class.new
      result = multiple_choice_answer.answer

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#submitted_answer' do
    xit 'submitted_answer' do
      multiple_choice_answer = described_class.new
      result = multiple_choice_answer.submitted_answer

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#answered_correctly?' do
    it 'answered_correctly?' do
      multiple_choice_answer = described_class.new
      result = multiple_choice_answer.answered_correctly?

      expect(result).not_to be_nil
    end
  end

end
