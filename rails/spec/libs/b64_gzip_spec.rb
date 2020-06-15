# frozen_string_literal: false

require 'spec_helper'

RSpec.describe B64Gzip do

  # TODO: auto-generated
  describe '.unpack' do
    xit 'unpack' do
      b64gzip_content = 'b64gzip_content'
      result = described_class.unpack(b64gzip_content)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.pack' do
    it 'pack' do
      content = ('content')
      result = described_class.pack(content)

      expect(result).not_to be_nil
    end
  end

end
