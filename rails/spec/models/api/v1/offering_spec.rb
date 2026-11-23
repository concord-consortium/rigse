# frozen_string_literal: false

require 'spec_helper'


RSpec.describe API::V1::Offering, type: :model do

  let(:teacher) { FactoryBot.create(:portal_teacher) }
  let(:clazz) { teacher.clazzes.first }
  let(:offering) { FactoryBot.create(:portal_offering, clazz: clazz) }

  def serialize_for(user)
    described_class.new(offering, 'http://', 'test.host', user, nil)
  end

  it 'exposes the class_word to a teacher of the class' do
    api = serialize_for(teacher.user)

    expect(api.class_word).to eq(clazz.class_word)
    expect(JSON.parse(api.to_json)['class_word']).to eq(clazz.class_word)
  end

  it 'exposes the class_word to an admin' do
    api = serialize_for(FactoryBot.generate(:admin_user))

    expect(api.class_word).to eq(clazz.class_word)
  end

  it 'withholds the class_word from a student of the class' do
    student = FactoryBot.create(:full_portal_student)
    clazz.students << student

    api = serialize_for(student.user)

    expect(api.class_word).to be_nil
    expect(JSON.parse(api.to_json)['class_word']).to be_nil
  end

  it 'withholds the class_word from a teacher of a different class' do
    other_teacher = FactoryBot.create(:portal_teacher)

    api = serialize_for(other_teacher.user)

    expect(api.class_word).to be_nil
  end

  it 'withholds the class_word when there is no current user' do
    api = serialize_for(nil)

    expect(api.class_word).to be_nil
  end

  describe 'students' do
    let(:student) { FactoryBot.create(:full_portal_student) }
    let(:learner) { FactoryBot.create(:full_portal_student, is_teacher_preview_student: true) }

    before do
      clazz.students << student
      clazz.students << learner
    end

    def student_json(api, portal_student)
      JSON.parse(api.to_json)['students'].find { |s| s['user_id'] == portal_student.user.id }
    end

    it 'sets is_teacher_preview_student only for a teacher preview student' do
      api = serialize_for(teacher.user)

      expect(student_json(api, learner)['is_teacher_preview_student']).to be true
      expect(student_json(api, learner)['name']).to eq(learner.user.name)
      expect(student_json(api, student)['is_teacher_preview_student']).to be false
    end

    it 'sets is_teacher_preview_student when names are anonymized' do
      api = described_class.new(offering, 'http://', 'test.host', teacher.user, nil, true)

      expect(student_json(api, learner)['is_teacher_preview_student']).to be true
      expect(student_json(api, learner)['name']).to eq("Student #{learner.id}")
      expect(student_json(api, student)['is_teacher_preview_student']).to be false
    end
  end

end
