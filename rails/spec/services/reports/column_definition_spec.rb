# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Reports::ColumnDefinition do

  # TODO: auto-generated
  describe '#write_header' do
    xit 'write_header' do
      opts = {}
      column_definition = described_class.new(opts)
      sheet = double('sheet')
      result = column_definition.write_header(sheet)

      expect(result).not_to be_nil
    end
  end

end
