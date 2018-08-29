# frozen_string_literal: false

require 'spec_helper'

RSpec.xdescribe SearchModelInterface do

  # TODO: auto-generated
  describe '.filtered_by_cohorts' do
    it 'filtered_by_cohorts' do
      allowed_cohorts = double('allowed_cohorts')
      result = described_class.filtered_by_cohorts(allowed_cohorts)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#material_type' do
    it 'material_type' do
      search_model_interface = described_class.new
      result = search_model_interface.material_type

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#icon_image' do
    it 'icon_image' do
      search_model_interface = described_class.new
      result = search_model_interface.icon_image

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#offerings_by_clazz' do
    it 'offerings_by_clazz' do
      search_model_interface = described_class.new
      clazz_ids = double('clazz_ids')
      result = search_model_interface.offerings_by_clazz(clazz_ids)

      expect(result).not_to be_nil
    end
  end

end
