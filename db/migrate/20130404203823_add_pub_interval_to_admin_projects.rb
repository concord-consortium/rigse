class AddPubIntervalToAdminProjects < ActiveRecord::Migration
  def self.up
    add_column :admin_projects, :pub_interval, :integer, :default => 30000
  end

  def self.down
    remove_column :admin_projects, :pub_interval
  end
end
