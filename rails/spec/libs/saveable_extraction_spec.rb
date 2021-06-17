# frozen_string_literal: false

require 'spec_helper'

class TestSaveableExtraction
  include SaveableExtraction
end

RSpec.describe SaveableExtraction do
  let(:saveable_extraction) { TestSaveableExtraction.new }
  # TODO: auto-generated
  describe '#logger' do
    it 'logger' do

      result = saveable_extraction.logger

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#process_open_response' do
    xit 'process_open_response' do

      parent_id = double('parent_id')
      answer = double('answer')
      is_final = double('is_final')
      result = saveable_extraction.process_open_response(parent_id, answer, is_final)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#process_multiple_choice' do
    xit 'process_multiple_choice' do

      embeddable_id = double('embeddable_id')
      choice_ids = double('choice_ids')
      rationales = double('rationales')
      is_final = double('is_final')
      result = saveable_extraction.process_multiple_choice(embeddable_id, choice_ids, rationales, is_final)

      expect(result).not_to be_nil
    end
  end

end
