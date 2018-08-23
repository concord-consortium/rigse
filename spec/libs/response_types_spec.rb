# frozen_string_literal: false

require 'spec_helper'

RSpec.describe ResponseTypes do

  # TODO: auto-generated
  describe '.saveable_types' do
    it 'saveable_types' do
      result = described_class.saveable_types

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#saveable_types' do
    it 'saveable_types' do
      response_types = Activity.new
      result = response_types.saveable_types

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.reportable_types' do
    it 'reportable_types' do
      result = described_class.reportable_types

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#reportable_types' do
    it 'reportable_types' do
      response_types = Activity.new
      result = response_types.reportable_types

      expect(result).not_to be_nil
    end
  end

end
