class TeacherProjectView < ActiveRecord::Migration[5.1]
  def change
    create_table :teacher_project_views do |t|
      t.belongs_to :viewed_project, null: false
      t.belongs_to :teacher, null: false
      t.timestamps
    end
  end
end
