class AddTeacherHomePathToAdminSettings < ActiveRecord::Migration[5.1]
  def change
    add_column :admin_settings, :teacher_home_path, :string, default: "/getting_started"
  end
end
