# frozen_string_literal: false

require 'spec_helper'

RSpec.xdescribe Otrunk::ObjectExtractor do

  # TODO: auto-generated
  describe '#get_text_property' do
    it 'get_text_property' do
      otml = double('otml')
      object_extractor = described_class.new(otml)
      element = double('element')
      property = double('property')
      result = object_extractor.get_text_property(element, property)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#get_property' do
    it 'get_property' do
      otml = double('otml')
      object_extractor = described_class.new(otml)
      element = double('element')
      property = double('property')
      result = object_extractor.get_property(element, property)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#get_property_path' do
    it 'get_property_path' do
      otml = double('otml')
      object_extractor = described_class.new(otml)
      element = double('element')
      path = double('path')
      result = object_extractor.get_property_path(element, path)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#resolve_elements' do
    it 'resolve_elements' do
      otml = double('otml')
      object_extractor = described_class.new(otml)
      elements = double('elements')
      result = object_extractor.resolve_elements(elements)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#resolve_id' do
    it 'resolve_id' do
      otml = double('otml')
      object_extractor = described_class.new(otml)
      id = double('id')
      result = object_extractor.resolve_id(id)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#resolve_local_id' do
    it 'resolve_local_id' do
      otml = double('otml')
      object_extractor = described_class.new(otml)
      local_id = double('local_id')
      result = object_extractor.resolve_local_id(local_id)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#resolve_path_id' do
    it 'resolve_path_id' do
      otml = double('otml')
      object_extractor = described_class.new(otml)
      parent_id = double('parent_id')
      path_id = double('path_id')
      result = object_extractor.resolve_path_id(parent_id, path_id)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#resolve_uuid' do
    it 'resolve_uuid' do
      otml = double('otml')
      object_extractor = described_class.new(otml)
      uuid = double('uuid')
      result = object_extractor.resolve_uuid(uuid)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#resolve_entry' do
    it 'resolve_entry' do
      otml = double('otml')
      object_extractor = described_class.new(otml)
      entry_key = double('entry_key')
      result = object_extractor.resolve_entry(entry_key)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#find_all' do
    it 'find_all' do
      otml = double('otml')
      object_extractor = described_class.new(otml)
      object_type = double('object_type')
      result = object_extractor.find_all(object_type) { |element| }

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#get_parent_id' do
    it 'get_parent_id' do
      otml = double('otml')
      object_extractor = described_class.new(otml)
      element = double('element')
      result = object_extractor.get_parent_id(element)

      expect(result).not_to be_nil
    end
  end

end
