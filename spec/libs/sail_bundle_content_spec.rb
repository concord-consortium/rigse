# frozen_string_literal: false

require 'spec_helper'

RSpec.describe SailBundleContent do

  let(:sail_bundle_content) { Dataservice::ConsoleContent.new }
  # TODO: auto-generated
  describe '#body' do
    it 'body' do
      
      result = sail_bundle_content.body

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#eportfolio' do
    it 'eportfolio' do
      
      result = sail_bundle_content.eportfolio

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#valid_xml?' do
    it 'valid_xml?' do
      
      result = sail_bundle_content.valid_xml?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#empty?' do
    it 'empty?' do
      
      result = sail_bundle_content.empty?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#sock_entry_values' do
    it 'sock_entry_values' do
      
      result = sail_bundle_content.sock_entry_values

      expect(result).not_to be_nil
    end
  end

end
