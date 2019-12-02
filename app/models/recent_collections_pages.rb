class RecentCollectionsPages < ActiveRecord::Base
  self.table_name = :recent_collections_pages

  attr_accessible :project_id, :teacher_id, :created_at, :updated_at
  belongs_to :project, :class_name => "Admin::Project"
  belongs_to :teacher, :class_name => "Portal::Teacher"
end
