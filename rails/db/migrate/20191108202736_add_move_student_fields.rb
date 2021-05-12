class AddMoveStudentFields < ActiveRecord::Migration[5.1]
  def change
    add_column :external_reports, :move_students_api_url, :text
    add_column :external_reports, :move_students_api_token, :string
  end
end
