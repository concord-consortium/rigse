class AddSavesStudentDataFieldToExternalActivity < ActiveRecord::Migration
  def change
    add_column :external_activities, :saves_student_data, :boolean, :default => true
  end
end
