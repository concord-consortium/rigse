class AddPubIntervalToAdminProjects < ActiveRecord::Migration
  def change
    add_column :admin_projects, :pub_interval, :integer, :default => 30000
  end
end
