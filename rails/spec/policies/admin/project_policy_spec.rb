# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Admin::ProjectPolicy do

  # TODO: auto-generated
  describe '#index?' do
    it 'index?' do
      project_policy = described_class.new(nil, nil)
      result = project_policy.index?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#update_edit_or_destroy?' do
    it 'update_edit_or_destroy?' do
      project_policy = described_class.new(nil, nil)
      result = project_policy.update_edit_or_destroy?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#not_anonymous?' do
    it 'not_anonymous?' do
      project_policy = described_class.new(nil, nil)
      result = project_policy.not_anonymous?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#visible?' do
    xit 'visible?' do
      project_policy = described_class.new(nil, nil)
      result = project_policy.visible?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#assign_to_material?' do
    it 'assign_to_material?' do
      project_policy = described_class.new(nil, nil)
      result = project_policy.assign_to_material?

      expect(result).to be_nil
    end
  end

end
