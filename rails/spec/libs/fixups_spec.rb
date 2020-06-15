# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Fixups do

  # TODO: auto-generated
  describe '.destroy_teacher' do
    it 'destroy_teacher' do
      result = described_class.destroy_teacher(Portal::Teacher.new)

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '.destroy_student' do
    xit 'destroy_student' do
      result = described_class.destroy_student(Portal::Student.new)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.remove_teachers_test_students' do
    it 'remove_teachers_test_students' do
      result = described_class.remove_teachers_test_students

      expect(result).not_to be_nil
    end
  end

end
