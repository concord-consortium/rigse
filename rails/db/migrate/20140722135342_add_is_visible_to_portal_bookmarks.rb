class AddIsVisibleToPortalBookmarks < ActiveRecord::Migration[5.1]
  def change
    add_column :portal_bookmarks, :is_visible, :boolean, :null => false, :default => true
  end
end
