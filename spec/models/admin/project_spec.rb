# frozen_string_literal: false

require 'spec_helper'


RSpec.describe Admin::Project, type: :model do



  # TODO: auto-generated
  describe '#changeable?' do
    it 'changeable?' do
      project = described_class.new
      user = FactoryBot.create(:user)
      result = project.changeable?(user)

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
  describe '.all_sorted' do
    it 'all_sorted' do
      result = described_class.all_sorted

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.with_landing_pages' do
    it 'with_landing_pages' do
      result = described_class.with_landing_pages

      expect(result).not_to be_nil
    end
  end

end
