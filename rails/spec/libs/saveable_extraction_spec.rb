# frozen_string_literal: false

require 'spec_helper'

RSpec.describe SaveableExtraction do
  let(:saveable_extraction) { Dataservice::BundleContent.new }
  # TODO: auto-generated
  describe '#logger' do
    it 'logger' do
      
      result = saveable_extraction.logger

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#extract_everything' do
    xit 'extract_everything' do
      
      extractor = double('extractor')
      result = saveable_extraction.extract_everything

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#extract_open_responses' do
    xit 'extract_open_responses' do
      
      extractor = double('extractor')
      result = saveable_extraction.extract_open_responses

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
  describe '#extract_multiple_choices' do
    xit 'extract_multiple_choices' do
      
      extractor = double('extractor')
      result = saveable_extraction.extract_multiple_choices

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#extract_multiple_choice_rationales' do
    xit 'extract_multiple_choice_rationales' do
      
      ot_choice_elem = double('ot_choice_elem')
      result = saveable_extraction.extract_multiple_choice_rationales(ot_choice_elem)

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

  # TODO: auto-generated
  describe '#extract_image_questions' do
    xit 'extract_image_questions' do
      
      result = saveable_extraction.extract_image_questions

      expect(result).not_to be_nil
    end
  end

end
