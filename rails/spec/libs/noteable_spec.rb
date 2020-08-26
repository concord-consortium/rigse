# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Noteable do


  let(:noteable) { FactoryBot.create(:activity) }
  # TODO: auto-generated
  describe '#teacher_note' do
    it 'teacher_note' do
      result = noteable.teacher_note

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#teacher_note=' do
    it 'teacher_note=' do
      note = ('note')
      result = noteable.teacher_note=(note)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#has_good_teacher_note?' do
    it 'has_good_teacher_note?' do
      result = noteable.has_good_teacher_note?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#teacher_note_otml' do
    xit 'teacher_note_otml' do
      result = noteable.teacher_note_otml

      expect(result).not_to be_nil
    end
  end

end
