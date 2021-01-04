# frozen_string_literal: false

require 'spec_helper'

RSpec.describe ParentInvestigation do

  # TODO: auto-generated
  describe '.parent_activities' do
    it 'parent_activities' do
      result = described_class.parent_activities

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.parent_activity' do
    it 'parent_activity' do
      activity = Activity.new
      result = described_class.parent_activity(activity)

      expect(result).not_to be_nil
    end
  end

end
