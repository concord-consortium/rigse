# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Portal::StudentClazzesHelper, type: :helper do

  # TODO: auto-generated
  describe '#students_in_class' do
    it 'works' do
      result = helper.students_in_class([])

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#make_chosen' do
    it 'works' do
      result = helper.make_chosen(1)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#student_add_dropdown' do
    xit 'works' do
      result = helper.student_add_dropdown(Factory.create(:portal_student))

      expect(result).not_to be_nil
    end
  end

end
