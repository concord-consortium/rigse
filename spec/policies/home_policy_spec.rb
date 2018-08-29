# frozen_string_literal: false

require 'spec_helper'

RSpec.describe HomePolicy do

  # TODO: auto-generated
  describe '#admin?' do
    it 'admin?' do
      home_policy = described_class.new(nil, nil)
      result = home_policy.admin?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#recent_activity?' do
    it 'recent_activity?' do
      home_policy = described_class.new(nil, nil)
      result = home_policy.recent_activity?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#authoring?' do
    it 'authoring?' do
      home_policy = described_class.new(nil, nil)
      result = home_policy.authoring?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#authoring_site_redirect?' do
    it 'authoring_site_redirect?' do
      home_policy = described_class.new(nil, nil)
      result = home_policy.authoring_site_redirect?

      expect(result).to be_nil
    end
  end

end
