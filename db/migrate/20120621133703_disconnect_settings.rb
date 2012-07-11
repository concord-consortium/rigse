class DisconnectSettings < ActiveRecord::Migration
  
  # local model so this migration will always work
  class AdminProject < ActiveRecord::Base
  end

  def self.up
  	# remove columns that are duplicated in the settings.yml file
    remove_column :admin_projects, :name
    remove_column :admin_projects, :url
    remove_column :admin_projects, :maven_jnlp_server_id
    remove_column :admin_projects, :maven_jnlp_family_id
    remove_column :admin_projects, :jnlp_version_str
    remove_column :admin_projects, :snapshot_enabled
    remove_column :admin_projects, :enable_default_users
    remove_column :admin_projects, :states_and_provinces

    # add 'active' to indicate which project record is the active one
    add_column :admin_projects, :active, :boolean

    # set the first project record to be active
    AdminProject.reset_column_information
    first_project = AdminProject.first 
    if first_project
      first_project.active = TRUE
      first_project.save
    end
  end

  def self.down
  	add_column :admin_projects, :name, :string
  	add_column :admin_projects, :url, :string
  	add_column :admin_projects, :maven_jnlp_server_id, :integer
  	add_column :admin_projects, :maven_jnlp_family_id, :integer
  	add_column :admin_projects, :jnlp_version_str, :string
  	add_column :admin_projects, :snapshot_enabled, :boolean
  	add_column :admin_projects, :enable_default_users, :boolean
  	add_column :admin_projects, :states_and_provinces, :text

  	remove_column :admin_projects, :active
  end
end
