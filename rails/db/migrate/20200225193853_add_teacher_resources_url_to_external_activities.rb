class AddTeacherResourcesUrlToExternalActivities < ActiveRecord::Migration[5.1]
  def change
    add_column :external_activities, :teacher_resources_url, :text
  end
end
