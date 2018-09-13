# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Saveable, type: :model do

  let(:object) { FactoryGirl.create(:multiple_choice)}
  
  # TODO: auto-generated
  describe '#submitted?' do
    xit 'submitted?' do
      saveable = object
      result = saveable.submitted?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#answer' do
    xit 'answer' do
      saveable = object
      result = saveable.answer

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#answer_type' do
    xit 'answer_type' do
      saveable = object
      result = saveable.answer_type

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#answered?' do
    xit 'answered?' do
      saveable = object
      result = saveable.answered?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#current_feedback' do
    xit 'current_feedback' do
      saveable = object
      result = saveable.current_feedback

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#current_score' do
    xit 'current_score' do
      saveable = object
      result = saveable.current_score

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#needs_review?' do
    xit 'needs_review?' do
      saveable = object
      result = saveable.needs_review?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#add_feedback' do
    xit 'add_feedback' do
      saveable = object
      feedback_opts = double('feedback_opts')
      result = saveable.add_feedback(feedback_opts)

      expect(result).not_to be_nil
    end
  end

end
