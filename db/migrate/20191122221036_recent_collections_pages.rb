class RecentCollectionsPages < ActiveRecord::Migration
  def change
    create_table :recent_collections_pages do |t|
      t.string :limit  => 36
      t.belongs_to :recent_project, null: false
      t.belongs_to :teacher, null: false
      t.timestamps
    end
    add_index :recent_collections_pages, :teacher_id
  end
end