class AddAllowAddTeacherToCohortOptionToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :can_add_teachers_to_cohorts, :boolean, default: false
  end
end
