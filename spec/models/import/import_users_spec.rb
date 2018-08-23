# frozen_string_literal: false

require 'spec_helper'


RSpec.describe Import::ImportUsers, type: :model do


  # TODO: auto-generated
  describe '#perform' do
    xit 'perform' do
      import_users = described_class.new(import_id: 1)
      result = import_users.perform

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#max_attempts' do
    it 'max_attempts' do
      import_users = described_class.new(import_id: 1)
      result = import_users.max_attempts

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#error' do
    xit 'error' do
      import_users = described_class.new(import_id: 1)
      job = double('job')
      exception = double('exception')
      result = import_users.error(job, exception)

      expect(result).not_to be_nil
    end
  end

end
