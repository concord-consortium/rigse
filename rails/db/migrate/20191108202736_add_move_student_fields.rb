class AddMoveStudentFields < ActiveRecord::Migration
  def change
    add_column :external_reports, :move_students_api_url, :text
    add_column :external_reports, :move_students_api_token, :string
  end
end
