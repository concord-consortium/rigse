class AddSectionToPortalClazz < ActiveRecord::Migration
  def self.up
    add_column :portal_clazzes, :section, :string
  end

  def self.down
    remove_column :portal_clazzes, :section
  end
end
