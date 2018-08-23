# frozen_string_literal: false

require 'spec_helper'


RSpec.describe Import::ImportExternalActivity, type: :model do


  # TODO: auto-generated
  describe '#perform' do
    xit 'perform' do
      import_external_activity = described_class.new
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
    xit 'error' do
      import_external_activity = described_class.new
      job = double('job')
      exception = double('exception')
      result = import_external_activity.error(job, exception)

      expect(result).not_to be_nil
    end
  end

end
