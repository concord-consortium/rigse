# frozen_string_literal: false

require 'spec_helper'


RSpec.describe CommonsLicense, type: :model do

  let(:license) { FactoryBot.create(:commons_license) }


  # TODO: auto-generated
  describe '#default_paths' do
    it 'default_paths' do
      commons_license = described_class.new
      result = commons_license.default_paths

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.for_select' do
    it 'for_select' do
      result = described_class.for_select

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.url' do
    it 'url' do
      fmt = double('fmt')
      result = described_class.url(license, fmt)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.image' do
    it 'image' do
      result = described_class.image(license)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.deed' do
    it 'deed' do
      result = described_class.deed(license)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.legal' do
    it 'legal' do
      result = described_class.legal(license)

      expect(result).not_to be_nil
    end
  end

end
