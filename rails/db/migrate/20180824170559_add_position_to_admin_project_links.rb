class AddPositionToAdminProjectLinks < ActiveRecord::Migration
  def change
    add_column :admin_project_links, :position, :integer, :default => 5
  end
end
