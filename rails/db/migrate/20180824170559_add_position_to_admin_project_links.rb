class AddPositionToAdminProjectLinks < ActiveRecord::Migration[5.1]
  def change
    add_column :admin_project_links, :position, :integer, :default => 5
  end
end
