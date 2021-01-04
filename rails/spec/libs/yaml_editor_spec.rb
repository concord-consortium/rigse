# frozen_string_literal: false

require 'spec_helper'

RSpec.describe YamlEditor do

  # TODO: auto-generated
  describe '#edit' do
    xit 'edit' do
      _filename = double('_filename')
      _defaults = double('_defaults')
      yaml_editor = described_class.new(_filename, _defaults)
      result = yaml_editor.edit

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#update' do
    xit 'update' do
      _filename = double('_filename')
      _defaults = double('_defaults')
      yaml_editor = described_class.new(_filename, _defaults)
      prop = double('prop')
      value = double('value')
      result = yaml_editor.update(prop, value)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#write_file' do
    xit 'write_file' do
      _filename = double('_filename')
      _defaults = double('_defaults')
      yaml_editor = described_class.new(_filename, _defaults)
      result = yaml_editor.write_file

      expect(result).not_to be_nil
    end
  end

end
