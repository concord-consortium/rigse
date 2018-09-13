# frozen_string_literal: false

require 'spec_helper'


RSpec.describe Embeddable::MultipleChoice, type: :model do



  # TODO: auto-generated
  describe '#by_offering' do
    xit 'by_offering' do
      multiple_choice = described_class.new
      offering = FactoryGirl.create(:portal_offering)
      result = multiple_choice.by_offering(offering)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#by_learner' do
    xit 'by_learner' do
      multiple_choice = described_class.new
      learner = double('learner')
      result = multiple_choice.by_learner(learner)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#first_by_learner' do
    xit 'first_by_learner' do
      multiple_choice = described_class.new
      learner = double('learner')
      result = multiple_choice.first_by_learner(learner)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.searchable_attributes' do
    it 'searchable_attributes' do
      result = described_class.searchable_attributes

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.cloneable_associations' do
    it 'cloneable_associations' do
      result = described_class.cloneable_associations

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#create_default_choices' do
    it 'create_default_choices' do
      multiple_choice = described_class.new
      result = multiple_choice.create_default_choices

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#to_xml' do
    it 'to_xml' do
      multiple_choice = described_class.new
      options = {}
      result = multiple_choice.to_xml(options)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#investigations' do
    it 'investigations' do
      multiple_choice = described_class.new
      result = multiple_choice.investigations

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#addChoice' do
    it 'addChoice' do
      multiple_choice = described_class.new
      choice_name = double('choice_name')
      result = multiple_choice.addChoice(choice_name)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#has_correct_answer?' do
    it 'has_correct_answer?' do
      multiple_choice = described_class.new
      result = multiple_choice.has_correct_answer?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#has_duplicate_choices?' do
    it 'has_duplicate_choices?' do
      multiple_choice = described_class.new
      result = multiple_choice.has_duplicate_choices?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#correct_answer' do
    it 'correct_answer' do
      multiple_choice = described_class.new
      result = multiple_choice.correct_answer

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#selection_ui' do
    it 'selection_ui' do
      multiple_choice = described_class.new
      result = multiple_choice.selection_ui

      expect(result).not_to be_nil
    end
  end

end
