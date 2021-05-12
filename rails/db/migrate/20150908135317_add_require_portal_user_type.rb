class AddRequirePortalUserType < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :require_portal_user_type, :boolean, :default => false
  end
end
