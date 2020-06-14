class AddLoggingToPortalClazzes < ActiveRecord::Migration
  def change
    add_column :portal_clazzes, :logging, :boolean, :default => false
  end
  def down
    remove_column :portal_clazzes, :logging
  end
end
