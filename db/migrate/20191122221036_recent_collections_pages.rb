class RecentCollectionsPages < ActiveRecord::Migration
  def change
    create_table :recent_collections_pages, :id => false do |t|
      t.references :project, null: false
      t.references :teacher, null: false
      t.timestamps
    end
    add_index :recent_collections_pages, :teacher_id
  end
end
