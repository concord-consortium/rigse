# frozen_string_literal: false

require 'spec_helper'

RSpec.describe API::V1::CollaborationPolicy do

  let(:context) { OpenStruct.new(user: FactoryGirl.create(:user), request: nil, params: [])}
  let(:api_v1_collaboration) { '' }
  describe '#create?' do
    it 'create?' do
      collaboration_policy = described_class.new(context, api_v1_collaboration)
      result = collaboration_policy.create?

      expect(result).to be false
    end
  end

  describe '#available_collaborators?' do
    it 'available_collaborators?' do
      collaboration_policy = described_class.new(context, api_v1_collaboration)
      result = collaboration_policy.available_collaborators?

      expect(result).to be false
    end
  end

  describe '#collaborators_data?' do
    xit 'collaborators_data?' do
      collaboration_policy = described_class.new(context, api_v1_collaboration)
      result = collaboration_policy.collaborators_data?

      expect(result).not_to be_nil
    end
  end

end
