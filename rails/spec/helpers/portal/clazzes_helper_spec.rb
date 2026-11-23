# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Portal::ClazzesHelper, type: :helper do

  # TODO: auto-generated
  describe '#render_portal_clazz_partial' do
    xit 'works' do
      result = helper.render_portal_clazz_partial('name', FactoryBot.create(:portal_clazz))

      expect(result).not_to be_nil
    end
  end

  describe '#student_roster_props' do
    let(:clazz) { FactoryBot.create(:portal_clazz) }
    let(:student) { FactoryBot.create(:full_portal_student) }
    let(:learner) { FactoryBot.create(:full_portal_student, is_teacher_preview_student: true) }

    before do
      clazz.students << student
      clazz.students << learner
      allow(helper).to receive(:policy).and_return(double(update_roster?: false, manage_students?: false, reset_password?: false))
      allow(helper).to receive(:current_settings).and_return(double(allow_default_class: false))
    end

    it 'sets is_teacher_preview_student only for a teacher preview student' do
      students = helper.student_roster_props(clazz)[:students]

      expect(students.find { |s| s[:student_id] == learner.id }[:is_teacher_preview_student]).to be true
      expect(students.find { |s| s[:student_id] == student.id }[:is_teacher_preview_student]).to be false
    end

    it 'does not change the name of a teacher preview student' do
      students = helper.student_roster_props(clazz)[:students]

      expect(students.find { |s| s[:student_id] == learner.id }[:name]).to eq("#{learner.user.last_name}, #{learner.user.first_name}")
    end
  end

end
