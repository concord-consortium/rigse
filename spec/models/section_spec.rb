# frozen_string_literal: false

require 'spec_helper'


RSpec.describe Section, type: :model do


  # TODO: auto-generated
  describe '.like' do # scope test
    it 'supports named scope like' do
      expect(described_class.limit(3).like('name')).to all(be_a(described_class))
    end
  end

  # TODO: auto-generated
  describe '#student_only' do
    xit 'student_only' do
      section = described_class.new
      result = section.student_only

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
  describe '.search_list' do
    it 'search_list' do
      options = {}
      result = described_class.search_list(options)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#parent' do
    it 'parent' do
      section = described_class.new
      result = section.parent

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#children' do
    it 'children' do
      section = described_class.new
      result = section.children

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#reportable_elements' do
    it 'reportable_elements' do
      section = described_class.new
      result = section.reportable_elements

      expect(result).not_to be_nil
    end
  end

end
