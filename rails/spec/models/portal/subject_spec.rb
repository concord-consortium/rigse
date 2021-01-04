# frozen_string_literal: false

require 'spec_helper'


RSpec.describe Portal::Subject, type: :model do


  # TODO: auto-generated
  describe '.searchable_attributes' do
    it 'searchable_attributes' do
      result = described_class.searchable_attributes

      expect(result).to eql %w{name description}
    end
  end

end
