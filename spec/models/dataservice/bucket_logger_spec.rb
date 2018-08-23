# frozen_string_literal: false

require 'spec_helper'


RSpec.describe Dataservice::BucketLogger, type: :model do


  # TODO: auto-generated
  describe '#most_recent_content' do
    it 'most_recent_content' do
      bucket_logger = described_class.new
      result = bucket_logger.most_recent_content

      expect(result).not_to be_nil
    end
  end

end
