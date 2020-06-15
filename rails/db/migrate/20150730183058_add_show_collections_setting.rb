class AddShowCollectionsSetting < ActiveRecord::Migration
  def up
    add_column :admin_settings, :show_collections_menu, :boolean, :default => false
  end

  def down
    remove_column :admin_settings, :show_collections_menu
  end
end
