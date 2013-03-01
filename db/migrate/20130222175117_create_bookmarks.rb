class CreateBookmarks < ActiveRecord::Migration
  def change
    create_table :bookmarks do |t|
      t.string :name
      t.string :type
      t.string :url
      t.integer :user_id
      t.timestamps
    end
  end
end
