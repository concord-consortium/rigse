class AddLockedToPortalOfferings < ActiveRecord::Migration[5.1]
  def change
    add_column :portal_offerings, :locked, :boolean, default: false
  end
end
