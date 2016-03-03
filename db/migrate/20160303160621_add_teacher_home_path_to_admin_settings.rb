class AddTeacherHomePathToAdminSettings < ActiveRecord::Migration
  def change
    add_column :admin_settings, :teacher_home_path, :string
  end
end
