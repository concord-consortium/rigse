class CleanupBookmarkTypes < ActiveRecord::Migration

  class Portal::Bookmark < ActiveRecord::Base
    self.table_name = :portal_bookmarks
  end

  class Admin::Project < ActiveRecord::Base
    self.table_name = :admin_projects
  end

  def up
    Portal::Bookmark.update_all({ type: 'Portal::GenericBookmark' }, { type: 'GenericBookmark' })
    Portal::Bookmark.update_all({ type: 'Portal::PadletBookmark' }, { type: 'PadletBookmark' })
    # Admin will have to re-enable bookmarks.
    Admin::Project.update_all({ enabled_bookmark_types: [] })
  end

  def down
    Portal::Bookmark.update_all({ type: 'GenericBookmark' }, { type: 'Portal::GenericBookmark' })
    Portal::Bookmark.update_all({ type: 'PadletBookmark' }, { type: 'Portal::PadletBookmark' })
  end
end
