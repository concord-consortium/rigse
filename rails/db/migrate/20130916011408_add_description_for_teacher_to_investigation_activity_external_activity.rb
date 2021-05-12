class AddDescriptionForTeacherToInvestigationActivityExternalActivity < ActiveRecord::Migration[5.1]
  def change
    add_column :investigations,      :description_for_teacher, :text
    add_column :activities,          :description_for_teacher, :text
    add_column :external_activities, :description_for_teacher, :text
  end
end
