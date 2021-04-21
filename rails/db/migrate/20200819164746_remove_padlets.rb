class RemovePadlets < ActiveRecord::Migration
  class Portal::Bookmark < ApplicationRecord
    self.table_name = :portal_bookmarks
  end

  def up
    Portal::Bookmark.where(:type => 'Portal::PadletBookmark').delete_all
  end

  def down
    # noop
  end
end
