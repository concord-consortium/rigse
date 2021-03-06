# frozen_string_literal: false

require 'spec_helper'

RSpec.describe ImagePolicy do

  # TODO: auto-generated
  describe '#index?' do
    it 'index?' do
      image_policy = described_class.new(nil, nil)
      result = image_policy.index?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#new_or_create?' do
    it 'new_or_create?' do
      image_policy = described_class.new(nil, nil)
      result = image_policy.new_or_create?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#update_edit_or_destroy?' do
    it 'update_edit_or_destroy?' do
      image_policy = described_class.new(nil, nil)
      result = image_policy.update_edit_or_destroy?

      expect(result).to be_nil
    end
  end

end
