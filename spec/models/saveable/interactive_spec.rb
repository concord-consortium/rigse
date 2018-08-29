# frozen_string_literal: false

require 'spec_helper'


RSpec.describe Saveable::Interactive, type: :model do

  # TODO: auto-generated
  describe '#embeddable' do
    it 'embeddable' do
      interactive = described_class.new
      result = interactive.embeddable

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#submitted_answer' do
    xit 'submitted_answer' do
      interactive = described_class.new
      result = interactive.submitted_answer

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#submitted?' do
    it 'submitted?' do
      interactive = described_class.new
      result = interactive.submitted?

      expect(result).not_to be_nil
    end
  end

end
