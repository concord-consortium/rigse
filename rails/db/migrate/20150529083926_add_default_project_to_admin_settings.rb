class AddDefaultProjectToAdminSettings < ActiveRecord::Migration
  def change
    add_column :admin_settings, :default_project_id, :integer
  end
end
