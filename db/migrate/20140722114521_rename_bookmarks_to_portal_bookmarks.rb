class RenameBookmarksToPortalBookmarks < ActiveRecord::Migration
  def change
    rename_table :bookmarks, :portal_bookmarks
    rename_table :bookmark_visits, :portal_bookmark_visits
  end
end
