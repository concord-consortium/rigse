class CreateNewAdminProjects < ActiveRecord::Migration
  def change
    create_table :admin_projects do |t|
      t.string  :name

      t.timestamps
    end
  end
end
