class RecentCollectionsPages < ActiveRecord::Base
  self.table_name = :recent_collections_pages

  attr_accessible :project_id, :teacher_id, :created_at, :updated_at
  belongs_to :recent_project, :class_name => "Admin::Project"
  belongs_to :teacher, :class_name => "Portal::Teacher"

  default_scope joins(:recent_project).order('recent_collections_pages.updated_at DESC')
end
