# frozen_string_literal: false

require 'spec_helper'

RSpec.describe API::V1::CollaborationPolicy do

  let(:context) { OpenStruct.new(user: FactoryBot.create(:user), request: nil, params: [])}
  # TODO: auto-generated
  describe '#create?' do
    it 'create?' do
      api_v1_collaboration = OpenStruct.new(user: FactoryBot.create(:user), request: nil, params: [])
      collaboration_policy = described_class.new(context, api_v1_collaboration)
      result = collaboration_policy.create?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#available_collaborators?' do
    it 'available_collaborators?' do
      api_v1_collaboration = OpenStruct.new(user: FactoryBot.create(:user), request: nil, params: [])
      collaboration_policy = described_class.new(context, api_v1_collaboration)
      result = collaboration_policy.available_collaborators?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#collaborators_data?' do
    xit 'collaborators_data?' do
      api_v1_collaboration = OpenStruct.new(user: FactoryBot.create(:user), request: nil, params: [])
      collaboration_policy = described_class.new(context, api_v1_collaboration)
      result = collaboration_policy.collaborators_data?

      expect(result).not_to be_nil
    end
  end

end
