class AddTeacherEditionOptionToExternalActivities < ActiveRecord::Migration
  def change
    add_column :external_activities, :has_teacher_edition, :boolean, :default => false
  end
end
