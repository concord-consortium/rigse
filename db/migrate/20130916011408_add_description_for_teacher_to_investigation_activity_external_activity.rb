class AddDescriptionForTeacherToInvestigationActivityExternalActivity < ActiveRecord::Migration
  def change
    add_column :investigations,      :description_for_teacher, :text
    add_column :activities,          :description_for_teacher, :text
    add_column :external_activities, :description_for_teacher, :text
  end
end
