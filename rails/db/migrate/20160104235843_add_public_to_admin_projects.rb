class AddPublicToAdminProjects < ActiveRecord::Migration[5.1]
  def change
    add_column :admin_projects, :public, :boolean, :default => true
  end
end
