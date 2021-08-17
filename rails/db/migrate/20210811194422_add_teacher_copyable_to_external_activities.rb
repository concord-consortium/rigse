class AddTeacherCopyableToExternalActivities < ActiveRecord::Migration[6.1]
  def change
    add_column :external_activities, :teacher_copyable, :boolean
  end
end
