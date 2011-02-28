class RemoveUserColumnFromAdminProjects < ActiveRecord::Migration
  def self.up
    remove_column :admin_projects, :user_id
  end

  def self.down
    add_column :admin_projects, :user_id, :integer
  end
end
