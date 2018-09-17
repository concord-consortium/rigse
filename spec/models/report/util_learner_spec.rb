# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Report::UtilLearner do

  let(:learner) { FactoryGirl.create(:full_portal_learner) }
  let(:activity) { FactoryGirl.create(:activity) }

  # TODO: auto-generated
  describe '#complete_number' do
    it 'complete_number' do
      util_learner = described_class.new(learner)
      result = util_learner.complete_number(activity)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#complete_percent' do
    it 'complete_percent' do
      util_learner = described_class.new(learner)
      result = util_learner.complete_percent(activity)

      expect(result).not_to be_nil
    end
  end

end
