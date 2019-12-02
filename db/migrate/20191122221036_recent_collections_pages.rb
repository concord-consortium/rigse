class RecentCollectionsPages < ActiveRecord::Migration
  def change
    create_table :recent_collections_pages do |t|
      t.string :uuid, :limit  => 36
      t.belongs_to :project, null: false
      t.belongs_to :teacher, null: false
      t.timestamps
    end
    add_index :recent_collections_pages, :teacher_id
  end
end
