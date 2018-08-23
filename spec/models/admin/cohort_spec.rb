# frozen_string_literal: false

require 'spec_helper'


RSpec.describe Admin::Cohort, type: :model do

  # TODO: auto-generated
  describe '#teachers' do
    it 'teachers' do
      cohort = described_class.new
      result = cohort.teachers

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#students' do
    it 'students' do
      cohort = described_class.new
      result = cohort.students

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#fullname' do
    it 'fullname' do
      cohort = described_class.new
      result = cohort.fullname

      expect(result).to be_nil
    end
  end

end
