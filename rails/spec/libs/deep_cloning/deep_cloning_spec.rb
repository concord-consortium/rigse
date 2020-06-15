# frozen_string_literal: false

require 'spec_helper'

RSpec.xdescribe DeepCloning do

  # TODO: auto-generated
  describe '#already_seen?' do
    it 'already_seen?' do
      deep_cloning = described_class.new
      obj = double('obj')
      result = deep_cloning.already_seen?(obj)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#record_object' do
    it 'record_object' do
      deep_cloning = described_class.new
      obj = double('obj')
      kopy = double('kopy')
      result = deep_cloning.record_object(obj, kopy)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#get_stored_object' do
    it 'get_stored_object' do
      deep_cloning = described_class.new
      obj = double('obj')
      result = deep_cloning.get_stored_object(obj)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#clone_object' do
    it 'clone_object' do
      deep_cloning = described_class.new
      obj = double('obj')
      opts = double('opts')
      result = deep_cloning.clone_object(obj, opts)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#set_no_duplicates' do
    it 'set_no_duplicates' do
      deep_cloning = described_class.new
      b = double('b')
      result = deep_cloning.set_no_duplicates(b)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#set_never_clone' do
    it 'set_never_clone' do
      deep_cloning = described_class.new
      attrs = double('attrs')
      result = deep_cloning.set_never_clone(attrs)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#get_never_clone' do
    it 'get_never_clone' do
      deep_cloning = described_class.new
      result = deep_cloning.get_never_clone

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#dup_with_deep_cloning' do
    it 'dup_with_deep_cloning' do
      deep_cloning = described_class.new
      options = double('options')
      result = deep_cloning.dup_with_deep_cloning(options)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#deep_clone' do
    it 'deep_clone' do
      deep_cloning = described_class.new
      options = double('options')
      result = deep_cloning.deep_clone(options)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#dc_initialize_attribute' do
    it 'dc_initialize_attribute' do
      deep_cloning = described_class.new
      kopy = double('kopy')
      attribute = double('attribute')
      result = deep_cloning.dc_initialize_attribute(kopy, attribute)

      expect(result).not_to be_nil
    end
  end

end
