class TeacherProjectView < ApplicationRecord
  self.table_name = :teacher_project_views

  belongs_to :viewed_project, :class_name => "Admin::Project"
  belongs_to :teacher, :class_name => "Portal::Teacher"

  default_scope { joins(:viewed_project).order('teacher_project_views.updated_at DESC') }
end
