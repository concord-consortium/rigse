# frozen_string_literal: false

require 'spec_helper'

RSpec.describe API::V1::AnswerPolicy do
  let(:context) { OpenStruct.new(user: FactoryBot.create(:user), request: nil, params: [])}

  # TODO: auto-generated
  describe '#student_answers?' do
    it 'student_answers?' do
      api_v1_answer = double('api_v1_answer')
      answer_policy = described_class.new(context, api_v1_answer)
      result = answer_policy.student_answers?

      expect(result).not_to be_nil
    end
  end

end
