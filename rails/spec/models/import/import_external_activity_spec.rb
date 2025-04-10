# frozen_string_literal: false

require 'spec_helper'


RSpec.describe Import::ImportExternalActivity, type: :model do

  let(:import) {Import::Import.new(import_type: Import::Import::IMPORT_TYPE_ACTIVITY)}
  let(:current_visitor) {FactoryBot.create(:user)}
  let(:auth_url) {'http://auth_url'}

  before(:each) do
    WebMock.stub_request(:post, auth_url)
      .to_return(status: 200, body: [].to_json, headers: { data: '{}' })
  end

  # TODO: auto-generated
  describe '#perform' do
    before do
      FactoryBot.create(:client, site_url: APP_CONFIG[:authoring_site_url])
    end

    it 'performs the job' do
      result = described_class.perform_now(import, {}, '/portal_url', auth_url, current_visitor.id)

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
    before do
      FactoryBot.create(:client, site_url: APP_CONFIG[:authoring_site_url])
    end

    it 'error' do
      import_external_activity = described_class.new
      import_external_activity.perform(import, {}, '/portal_url', auth_url, 123)
      result = import_external_activity.error(nil, nil)

      expect(result).not_to be_nil
    end
  end

end
