# frozen_string_literal: false

require 'spec_helper'


RSpec.describe Search::SearchMaterial do

  let(:material) { Activity.new }

  # TODO: auto-generated
  describe '#populateMaterialData' do
    xit 'populateMaterialData' do
      user = FactoryGirl.create(:user)
      search_material = described_class.new(material, user)
      result = search_material.populateMaterialData

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#get_page_title_and_meta_tags' do
    xit 'get_page_title_and_meta_tags' do
      user = FactoryGirl.create(:user)
      search_material = described_class.new(material, user)
      result = search_material.get_page_title_and_meta_tags

      expect(result).not_to be_nil
    end
  end

end
