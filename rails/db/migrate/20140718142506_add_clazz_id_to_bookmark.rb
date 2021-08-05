class AddClazzIdToBookmark < ActiveRecord::Migration[5.1]
  def change
    add_column :bookmarks, :clazz_id, :integer
    add_index :bookmarks, :clazz_id
  end
end
