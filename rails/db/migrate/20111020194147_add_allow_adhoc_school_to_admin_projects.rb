class AddAllowAdhocSchoolToAdminProjects < ActiveRecord::Migration[5.1]
  def self.up
    add_column :admin_projects, :allow_adhoc_schools, :boolean, :default=>false
  end

  def self.down
    remove_column :admin_projects, :allow_adhoc_schools
  end
end
