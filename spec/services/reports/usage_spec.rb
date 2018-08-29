# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Reports::Usage do

  # TODO: auto-generated
  describe '#sorted_learners' do
    it 'sorted_learners' do
      opts = {}
      usage = described_class.new(opts)
      result = usage.sorted_learners

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#run_report' do
    it 'run_report' do
      opts = {}
      usage = described_class.new(opts)
      result = usage.run_report

      expect(result).not_to be_nil
    end
  end

end
