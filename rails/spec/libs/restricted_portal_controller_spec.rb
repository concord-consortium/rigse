# frozen_string_literal: false

require 'spec_helper'

RSpec.xdescribe RestrictedPortalController do

  # TODO: auto-generated
  describe '#teacher_admin' do
    it 'teacher_admin' do
      restricted_portal_controller = described_class.new
      result = restricted_portal_controller.teacher_admin

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#student_teacher_admin' do
    it 'student_teacher_admin' do
      restricted_portal_controller = described_class.new
      result = restricted_portal_controller.student_teacher_admin

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#student_teacher_or_admin' do
    it 'student_teacher_or_admin' do
      restricted_portal_controller = described_class.new
      result = restricted_portal_controller.student_teacher_or_admin

      expect(result).not_to be_nil
    end
  end

end
