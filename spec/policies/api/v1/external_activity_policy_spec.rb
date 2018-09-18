# frozen_string_literal: false

require 'spec_helper'

RSpec.describe API::V1::ExternalActivityPolicy do

  # TODO: auto-generated
  describe '#create?' do
    xit 'create?' do
      context = nil
      api_v1_external_activity = double('api_v1_external_activity')
      external_activity_policy = described_class.new(context, api_v1_external_activity)
      result = external_activity_policy.create?

      expect(result).not_to be_nil
    end
  end

end
