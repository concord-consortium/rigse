class AddDefaultClassFlagToPortalClazz < ActiveRecord::Migration[5.1]
  def self.up
    add_column :portal_clazzes, :default_class, :boolean, :default => false
  end

  def self.down
    remove_column :portal_clazzes, :default_class
  end
end
