class TeacherProjectView < ActiveRecord::Base
  self.table_name = :teacher_project_views

  attr_accessible :viewed_project_id, :teacher_id, :created_at, :updated_at, :viewed_project, :teacher
  belongs_to :viewed_project, :class_name => "Admin::Project"
  belongs_to :teacher, :class_name => "Portal::Teacher"

  default_scope { joins(:viewed_project).order('teacher_project_views.updated_at DESC') }
end
