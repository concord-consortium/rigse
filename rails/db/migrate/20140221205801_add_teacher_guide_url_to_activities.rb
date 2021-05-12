class AddTeacherGuideUrlToActivities < ActiveRecord::Migration[5.1]
  def change
    add_column :external_activities, :teacher_guide_url, :string
    add_column :investigations, :teacher_guide_url, :string
    add_column :activities, :teacher_guide_url, :string
  end
end
