class AddProjectUserFlags < ActiveRecord::Migration
  def up
    # added primary key so the is_* attributes can be updated in the controller
    add_column :admin_project_users, :id, :primary_key

    add_column :admin_project_users, :is_admin, :boolean, :default => false
    add_column :admin_project_users, :is_researcher, :boolean, :default => false
    add_column :admin_project_users, :is_member, :boolean, :default => false

    # set all existing project users as members
    Admin::ProjectUser.update_all(is_member: true)
  end

  def down
    remove_column :admin_project_users, :id, :primary_key
    remove_column :admin_project_users, :is_admin, :boolean, :default => false
    remove_column :admin_project_users, :is_researcher, :boolean, :default => false
    remove_column :admin_project_users, :is_member, :boolean, :default => false
  end
end
