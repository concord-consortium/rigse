# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Report::Util do

  let(:offering) { FactoryGirl.create(:portal_offering) }
  let(:learner) { Portal::Learner.new }

  # TODO: auto-generated
  describe '.factory' do
    it 'factory' do
      result = described_class.factory(offering)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.reload' do
    it 'reload' do
      result = described_class.reload(offering)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.reload_without_filters' do
    it 'reload_without_filters' do
      result = described_class.reload_without_filters(offering)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.invalidate' do
    it 'invalidate' do
      result = described_class.invalidate(offering)

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '.maintenance' do
    it 'maintenance' do
      result = described_class.maintenance

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#saveable' do
    xit 'saveable' do
      offering_or_learner = double('offering_or_learner')
      util = described_class.new(offering_or_learner)
      embeddable = FactoryGirl.create(:open_response)
      result = util.saveable(learner, embeddable)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#saveables' do
    it 'saveables' do
      offering_or_learner = offering
      show_only_active_learners = ('show_only_active_learners')
      skip_filters = ('skip_filters')
      util = described_class.new(offering_or_learner, show_only_active_learners, skip_filters)
      options = {}
      result = util.saveables(options)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#embeddables' do
    it 'embeddables' do
      offering_or_learner = offering
      util = described_class.new(offering_or_learner)
      options = {}
      result = util.embeddables(options)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#complete_number' do
    it 'complete_number' do
      offering_or_learner = offering
      util = described_class.new(offering_or_learner)
      activity = Activity.new
      result = util.complete_number(learner, activity)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#complete_percent' do
    xit 'complete_percent' do
      offering_or_learner = offering
      util = described_class.new(offering_or_learner)
      learner = double('learner')
      activity = Activity.new
      result = util.complete_percent(learner, activity)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#answered_number' do
    it 'answered_number' do
      offering_or_learner = offering
      util = described_class.new(offering_or_learner)
      result = util.answered_number(learner)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#correct_number' do
    it 'correct_number' do
      offering_or_learner = offering
      util = described_class.new(offering_or_learner)
      result = util.correct_number(learner)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#correct_percent' do
    it 'correct_percent' do
      offering_or_learner = offering
      util = described_class.new(offering_or_learner)
      result = util.correct_percent(learner)

      expect(result).not_to be_nil
    end
  end

end
