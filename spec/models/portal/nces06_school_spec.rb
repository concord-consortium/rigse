# frozen_string_literal: false

require 'spec_helper'


RSpec.describe Portal::Nces06School, type: :model do


  # TODO: auto-generated
  describe '.searchable_attributes' do
    it 'searchable_attributes' do
      result = described_class.searchable_attributes

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#portal_school_created?' do
    it 'portal_school_created?' do
      nces06_school = described_class.new
      result = nces06_school.portal_school_created?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#capitalized_name' do
    it 'capitalized_name' do
      nces06_school = described_class.new('SCHNAM' => 'a name')
      result = nces06_school.capitalized_name

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#phone' do
    it 'phone' do
      nces06_school = described_class.new
      result = nces06_school.phone

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#address' do
    it 'address' do
      nces06_school = described_class.new('MSTREE' => 'street', 'MCITY' => 'city')
      result = nces06_school.address

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#geographic_location' do
    it 'geographic_location' do
      nces06_school = described_class.new
      result = nces06_school.geographic_location

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#student_teacher_ratio' do
    it 'student_teacher_ratio' do
      nces06_school = described_class.new
      result = nces06_school.student_teacher_ratio

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#percent_free_reduced_lunch' do
    it 'percent_free_reduced_lunch' do
      nces06_school = described_class.new
      result = nces06_school.percent_free_reduced_lunch

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#description' do
    xit 'description' do
      nces06_school = described_class.new('SCHNAM' => 'street')
      result = nces06_school.description

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#summary' do
    xit 'summary' do
      nces06_school = described_class.new('MSTREE' => 'street', 'MCITY' => 'city')
      result = nces06_school.summary

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#active_grades' do
    xit 'active_grades' do
      nces06_school = described_class.new
      result = nces06_school.active_grades

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#grade_match' do
    xit 'grade_match' do
      nces06_school = described_class.new
      grades = '1'
      result = nces06_school.grade_match(grades)

      expect(result).not_to be_nil
    end
  end

end
