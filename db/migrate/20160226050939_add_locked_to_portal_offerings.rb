class AddLockedToPortalOfferings < ActiveRecord::Migration
  def change
    add_column :portal_offerings, :locked, :boolean, default: false
  end
end
