class AddAnonymousBrowseMaterialsToAdminProject < ActiveRecord::Migration
  def up
    add_column :admin_projects, :anonymous_can_browse_materials, :boolean, :default => true

    execute "UPDATE admin_projects SET anonymous_can_browse_materials = true WHERE id > 0"
  end

  def down
    remove_column :admin_projects, :anonymous_can_browse_materials
  end
end
