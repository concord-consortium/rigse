# frozen_string_literal: false

require 'spec_helper'

RSpec.describe HasOrBelongsToManyExtensions do

  # TODO: auto-generated
  describe '#exists?' do
    xit 'exists?' do
      has_or_belongs_to_many_extensions = described_class.new
      model = double('model')
      result = has_or_belongs_to_many_extensions.exists?(model)

      expect(result).not_to be_nil
    end
  end

end
