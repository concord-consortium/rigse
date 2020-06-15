# frozen_string_literal: false

require 'spec_helper'

RSpec.xdescribe RestrictedTeacherController do

  # TODO: auto-generated
  describe '#check_teacher_owns_clazz' do
    it 'check_teacher_owns_clazz' do
      restricted_teacher_controller = described_class.new
      result = restricted_teacher_controller.check_teacher_owns_clazz

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#check_teacher_owns_clazz_id' do
    it 'check_teacher_owns_clazz_id' do
      restricted_teacher_controller = described_class.new
      clazz_id = double('clazz_id')
      result = restricted_teacher_controller.check_teacher_owns_clazz_id(clazz_id)

      expect(result).not_to be_nil
    end
  end

end
