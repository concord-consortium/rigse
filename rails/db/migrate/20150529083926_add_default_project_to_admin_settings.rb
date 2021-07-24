class AddDefaultProjectToAdminSettings < ActiveRecord::Migration[5.1]
  def change
    add_column :admin_settings, :default_project_id, :integer
  end
end
