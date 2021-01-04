# frozen_string_literal: false

require 'spec_helper'


RSpec.describe Dataservice::BundleContent, type: :model do

  # TODO: auto-generated
  describe '.searchable_attributes' do
    it 'searchable_attributes' do
      result = described_class.searchable_attributes

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#user' do
    it 'user' do
      bundle_content = described_class.new
      result = bundle_content.user

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#otml' do
    it 'otml' do
      bundle_content = described_class.new
      result = bundle_content.otml

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#name' do
    xit 'name' do
      bundle_content = described_class.new
      result = bundle_content.name

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#owner' do
    xit 'owner' do
      bundle_content = described_class.new
      result = bundle_content.owner

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#collaboration_owner_bundle?' do
    xit 'collaboration_owner_bundle?' do
      bundle_content = described_class.new
      result = bundle_content.collaboration_owner_bundle?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#session_uuid' do
    it 'session_uuid' do
      bundle_content = described_class.new
      result = bundle_content.session_uuid

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#previous_session_uuid' do
    it 'previous_session_uuid' do
      bundle_content = described_class.new
      result = bundle_content.previous_session_uuid

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#session_start' do
    it 'session_start' do
      bundle_content = described_class.new
      result = bundle_content.session_start

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#session_stop' do
    it 'session_stop' do
      bundle_content = described_class.new
      result = bundle_content.session_stop

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#local_ip' do
    it 'local_ip' do
      bundle_content = described_class.new
      result = bundle_content.local_ip

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#otml_hash' do
    it 'otml_hash' do
      bundle_content = described_class.new
      result = bundle_content.otml_hash

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#record_bundle_processing' do
    it 'record_bundle_processing' do
      bundle_content = described_class.new
      result = bundle_content.record_bundle_processing

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#process_bundle' do
    it 'process_bundle' do
      bundle_content = described_class.new
      result = bundle_content.process_bundle

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#extract_otml' do
    it 'extract_otml' do
      bundle_content = described_class.new
      result = bundle_content.extract_otml

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#convert_otml_to_body' do
    it 'convert_otml_to_body' do
      bundle_content = described_class.new
      result = bundle_content.convert_otml_to_body

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#process_blobs' do
    it 'process_blobs' do
      bundle_content = described_class.new
      result = bundle_content.process_blobs

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#bundle_content_return_address' do
    xit 'bundle_content_return_address' do
      bundle_content = described_class.new
      result = bundle_content.bundle_content_return_address

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#otml_empty?' do
    it 'otml_empty?' do
      bundle_content = described_class.new
      result = bundle_content.otml_empty?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#delayed_process_bundle' do
    xit 'delayed_process_bundle' do
      bundle_content = described_class.new
      result = bundle_content.delayed_process_bundle

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#extract_saveables' do
    xit 'extract_saveables' do
      bundle_content = described_class.new
      result = bundle_content.extract_saveables

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#description' do
    it 'description' do
      bundle_content = described_class.new
      result = bundle_content.description

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#copy_to_collaborators' do
    it 'copy_to_collaborators' do
      bundle_content = described_class.new
      result = bundle_content.copy_to_collaborators

      expect(result).to be_nil
    end
  end

end
