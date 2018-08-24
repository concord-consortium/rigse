# frozen_string_literal: false

require 'spec_helper'

RSpec.describe SearchInteractives do

  # TODO: auto-generated
  describe '#fetch_available_filter_options' do
    it 'fetch_available_filter_options' do
      opts = {}
      search_interactives = described_class.new(opts)
      result = search_interactives.fetch_available_filter_options

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#fetch_custom_search_params' do
    it 'fetch_custom_search_params' do
      opts = {}
      search_interactives = described_class.new(opts)
      result = search_interactives.fetch_custom_search_params

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#add_custom_search_filters' do
    it 'add_custom_search_filters' do
      opts = {}
      search_interactives = described_class.new(opts)
      search = double('search')
      result = search_interactives.add_custom_search_filters(search)

      expect(result).to be_nil
    end
  end

end
