class AddRequirePortalUserType < ActiveRecord::Migration
  def change
    add_column :users, :require_portal_user_type, :boolean, :default => false
  end
end
