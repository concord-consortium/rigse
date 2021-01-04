# frozen_string_literal: false

require 'spec_helper'


RSpec.describe Saveable::ImageQuestionAnswer, type: :model do



  # TODO: auto-generated
  describe '#answer' do
    it 'answer' do
      image_question_answer = described_class.new
      result = image_question_answer.answer

      expect(result).not_to be_nil
    end
  end

end
