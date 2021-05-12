class AddDefaultOfferingToPortalOfferings < ActiveRecord::Migration[5.1]
  def self.up
    add_column :portal_offerings, :default_offering, :boolean, :default => false
  end

  def self.down
    remove_column :portal_offerings, :default_offering
  end
end
