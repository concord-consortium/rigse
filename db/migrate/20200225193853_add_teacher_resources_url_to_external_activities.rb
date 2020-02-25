class AddTeacherResourcesUrlToExternalActivities < ActiveRecord::Migration
  def change
    add_column :external_activities, :teacher_resources_url, :text
  end
end
