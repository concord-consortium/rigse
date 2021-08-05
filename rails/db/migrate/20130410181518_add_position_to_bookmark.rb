class AddPositionToBookmark < ActiveRecord::Migration[5.1]
  def change
    add_column :bookmarks, :position, :integer
  end
end
