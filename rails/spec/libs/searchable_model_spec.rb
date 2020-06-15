# frozen_string_literal: false

require 'spec_helper'

RSpec.xdescribe SearchableModel do

  # TODO: auto-generated
  describe '#search' do
    it 'search' do
      searchable_model = described_class.new
      search = double('search')
      page = double('page')
      user = double('user')
      includes = double('includes')
      result = searchable_model.search(search, page, user, includes)

      expect(result).not_to be_nil
    end
  end

end
