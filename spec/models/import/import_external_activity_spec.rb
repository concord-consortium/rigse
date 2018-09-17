# frozen_string_literal: false

require 'spec_helper'


RSpec.describe Import::ImportExternalActivity, type: :model do

  let(:import) {Import::Import.new(import_type: Import::Import::IMPORT_TYPE_ACTIVITY)}

  # TODO: auto-generated
  describe '#perform' do
    before do
      FactoryGirl.create(:client, :site_url => APP_CONFIG[:authoring_site_url])
    end
    it 'perform' do
      import_external_activity = described_class.new(import, {}, '/portal_url', 'http://auth_url')
      WebMock.stub_request(:post, 'http://auth_url')
          .to_return(:status => 200, :body => [].to_json, headers: {data: '{}'})

      result = import_external_activity.perform
      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#max_attempts' do
    it 'max_attempts' do
      import_external_activity = described_class.new
      result = import_external_activity.max_attempts

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#error' do
    it 'error' do
      import_external_activity = described_class.new(import)
      result = import_external_activity.error(nil, nil)

      expect(result).not_to be_nil
    end
  end

end
