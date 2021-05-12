class AddActiveFlagToPortalOfferings < ActiveRecord::Migration[5.1]
  def self.up
    add_column :portal_offerings, :active, :boolean, :default => true
  end

  def self.down
    remove_column :portal_offerings, :active
  end
end
