# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Noteable do


  let(:noteable) { FactoryBot.create(:activity) }

  # TODO: auto-generated
  describe '#author_note' do
    xit 'author_note' do
      noteable = described_class
      result = noteable.author_note

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#author_note=' do
    it 'author_note=' do
      note = ('note')
      result = noteable.author_note=(note)

      expect(result).not_to be_nil
    end
  end

end
