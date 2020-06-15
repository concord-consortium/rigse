# frozen_string_literal: false

require 'spec_helper'


RSpec.describe Dataservice::PeriodicBundleContent, type: :model do



  # TODO: auto-generated
  describe '#otml' do
    it 'otml' do
      periodic_bundle_content = described_class.new
      result = periodic_bundle_content.otml

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#otml=' do
    it 'otml=' do
      periodic_bundle_content = described_class.new
      val = double('val')
      result = periodic_bundle_content.otml=(val)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#process_bundle' do
    it 'process_bundle' do
      periodic_bundle_content = described_class.new
      result = periodic_bundle_content.process_bundle

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#record_bundle_processing' do
    it 'record_bundle_processing' do
      periodic_bundle_content = described_class.new
      result = periodic_bundle_content.record_bundle_processing

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#delayed_process_bundle' do
    xit 'delayed_process_bundle' do
      periodic_bundle_content = described_class.new
      result = periodic_bundle_content.delayed_process_bundle

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#extract_parts' do
    xit 'extract_parts' do
      periodic_bundle_content = described_class.new
      result = periodic_bundle_content.extract_parts

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#extract_saveables' do
    xit 'extract_saveables' do
      periodic_bundle_content = described_class.new
      result = periodic_bundle_content.extract_saveables

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#copy_to_collaborators' do
    it 'copy_to_collaborators' do
      periodic_bundle_content = described_class.new
      result = periodic_bundle_content.copy_to_collaborators

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#has_state_root?' do
    it 'has_state_root?' do
      periodic_bundle_content = described_class.new
      result = periodic_bundle_content.has_state_root?

      expect(result).to be_nil
    end
  end

end
