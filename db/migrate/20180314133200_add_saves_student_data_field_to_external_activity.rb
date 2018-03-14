class AddSavesStudentDataFieldToExternalActivity < ActiveRecord::Migration
  def self.up
    add_column :external_activities, :saves_student_data, :boolean, :default => true
  end

  def self.down
    remove_column :external_activities, :saves_student_data
  end
end
