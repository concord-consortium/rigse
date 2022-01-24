class AddIsArchivedToPortalClazzes < ActiveRecord::Migration[6.1]
  def change
    add_column :portal_clazzes, :is_archived, :boolean, :default => false
  end
end
