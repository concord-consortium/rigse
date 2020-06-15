class CreateAdminProjectLinks < ActiveRecord::Migration
  def change
    create_table :admin_project_links do |t|
      t.integer :project_id
      t.text :name
      t.text :href

      t.timestamps
    end
  end
end
