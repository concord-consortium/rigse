class RemoveIsMemberFromAdminProjectUser < ActiveRecord::Migration
  class Admin::ProjectUser < ActiveRecord::Base
    self.table_name = 'admin_project_users'
  end

  def up
    remove_column :admin_project_users, :is_member
    # Remove objects that are redundant now.
    Admin::ProjectUser.where(is_admin: false, is_researcher: false).delete_all
  end

  def down
    add_column :admin_project_users, :is_member, :boolean
  end
end
