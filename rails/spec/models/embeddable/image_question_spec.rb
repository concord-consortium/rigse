# frozen_string_literal: false

require 'spec_helper'


RSpec.describe Embeddable::ImageQuestion, type: :model do

  # TODO: auto-generated
  describe '.searchable_attributes' do
    it 'searchable_attributes' do
      result = described_class.searchable_attributes

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.default_prompt' do
    it 'default_prompt' do
      result = described_class.default_prompt

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#description' do
    it 'description' do
      image_question = described_class.new
      result = image_question.description

      expect(result).not_to be_nil
    end
  end

end
