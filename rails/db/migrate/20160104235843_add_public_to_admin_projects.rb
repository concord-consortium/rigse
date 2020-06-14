class AddPublicToAdminProjects < ActiveRecord::Migration
  def change
    add_column :admin_projects, :public, :boolean, :default => true
  end
end
