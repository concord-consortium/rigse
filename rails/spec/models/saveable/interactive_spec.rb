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
end
