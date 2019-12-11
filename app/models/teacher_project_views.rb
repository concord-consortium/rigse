class TeacherProjectViews < ActiveRecord::Base
  self.table_name = :teacher_project_views

  attr_accessible :viewed_projects_id, :teacher_id, :created_at, :updated_at
  belongs_to :viewed_projects, :class_name => "Admin::Project"
  belongs_to :teacher, :class_name => "Portal::Teacher"

  default_scope joins(:viewed_projects).order('teacher_project_views.updated_at DESC')
end
