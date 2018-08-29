# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Portal::BookmarksHelper, type: :helper do

  # TODO: auto-generated
  describe '#bookmarks_enabled' do
    it 'works' do
      result = helper.bookmarks_enabled

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#each_available_claz' do
    it 'works' do
      result = helper.each_available_claz { |claz, type| }

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#render_add_bookmark_buttons' do
    it 'works' do
      result = helper.render_add_bookmark_buttons

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#bookmark_dom_item' do
    xit 'works' do
      result = helper.bookmark_dom_item('mark')

      expect(result).not_to be_nil
    end
  end

end
