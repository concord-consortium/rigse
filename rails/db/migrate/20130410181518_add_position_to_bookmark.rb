class AddPositionToBookmark < ActiveRecord::Migration
  def change
    add_column :bookmarks, :position, :integer
  end
end
