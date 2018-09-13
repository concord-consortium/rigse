# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Reports::Detail do

  # TODO: auto-generated
  describe '#sorted_learners' do
    it 'sorted_learners' do
      opts = {}
      detail = described_class.new(opts)
      result = detail.sorted_learners

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#setup_sheet_for_runnable' do
    xit 'setup_sheet_for_runnable' do
      opts = {}
      detail = described_class.new(opts)
      runnable = double('runnable')
      result = detail.setup_sheet_for_runnable(runnable)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#setup_sheet_runnables' do
    xit 'setup_sheet_runnables' do
      opts = {}
      detail = described_class.new(opts)
      container = double('container')
      reportable_header_counter = double('reportable_header_counter')
      header_defs = double('header_defs')
      answer_defs = double('answer_defs')
      expected_answers = double('expected_answers')
      result = detail.setup_sheet_runnables(container, reportable_header_counter, header_defs, answer_defs, expected_answers)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#run_report' do
    it 'run_report' do
      opts = {}
      detail = described_class.new(opts)
      result = detail.run_report

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#default_answer_for' do
    it 'default_answer_for' do
      opts = {}
      detail = described_class.new(opts)
      embeddable = FactoryGirl.create(:open_response)
      result = detail.default_answer_for(embeddable)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#get_expected_answer' do
    it 'get_expected_answer' do
      opts = {}
      detail = described_class.new(opts)
      reportable = double('reportable')
      result = detail.get_expected_answer(reportable)

      expect(result).not_to be_nil
    end
  end

end
