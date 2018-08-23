# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Dataservice::ProcessExternalActivityDataJobPolicy do

  let(:context) { OpenStruct.new(request: [], params: {id_or_key: ''}, user: Factory.create(:user) )}

  # TODO: auto-generated
  describe '#create?' do
    xit 'create?' do
      process_external_activity_data_job_policy = described_class.new(context, nil)
      result = process_external_activity_data_job_policy.create?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#create_by_protocol_version?' do
    xit 'create_by_protocol_version?' do
      process_external_activity_data_job_policy = described_class.new(context, nil)
      result = process_external_activity_data_job_policy.create_by_protocol_version?

      expect(result).not_to be_nil
    end
  end

end
