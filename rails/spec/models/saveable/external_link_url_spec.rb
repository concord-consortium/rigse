# frozen_string_literal: false

require 'spec_helper'


RSpec.describe Saveable::ExternalLinkUrl, type: :model do



  # TODO: auto-generated
  describe '#answer' do
    it 'answer' do
      external_link_url = described_class.new
      result = external_link_url.answer

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#answer=' do
    it 'answer=' do
      external_link_url = described_class.new
      ans = 'x'
      result = external_link_url.answer=(ans)

      expect(result).not_to be_nil
    end
  end

end
