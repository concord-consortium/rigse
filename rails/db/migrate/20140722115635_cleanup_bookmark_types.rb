class CleanupBookmarkTypes < ActiveRecord::Migration

  class Portal::Bookmark < ActiveRecord::Base
    self.table_name = :portal_bookmarks
  end

  class Admin::Project < ActiveRecord::Base
    self.table_name = :admin_projects
  end

  def up
    Portal::Bookmark.where({ type: 'GenericBookmark' }).update_all({ type: 'Portal::GenericBookmark' })
    Portal::Bookmark.where({ type: 'PadletBookmark' }).update_all({ type: 'Portal::PadletBookmark' })
    # Admin will have to re-enable bookmarks.
    Admin::Project.update_all({ enabled_bookmark_types: [] })
  end

  def down
    Portal::Bookmark.where({ type: 'Portal::GenericBookmark' }).update_all({ type: 'GenericBookmark' })
    Portal::Bookmark.where({ type: 'Portal::PadletBookmark' }).update_all({ type: 'PadletBookmark' })
  end
end
