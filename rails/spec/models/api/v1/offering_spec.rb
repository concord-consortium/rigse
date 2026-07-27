# frozen_string_literal: false

require 'spec_helper'


RSpec.describe API::V1::Offering, type: :model do

  it 'exposes the class_word from the offering clazz' do
    teacher = FactoryBot.create(:portal_teacher)
    clazz = teacher.clazzes.first
    offering = FactoryBot.create(:portal_offering, clazz: clazz)

    api = described_class.new(offering, 'http://', 'test.host', teacher.user, nil)

    expect(api.class_word).to eq(clazz.class_word)
    expect(JSON.parse(api.to_json)['class_word']).to eq(clazz.class_word)
  end

end
