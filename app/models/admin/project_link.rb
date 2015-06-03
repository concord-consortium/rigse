class Admin::ProjectLink < ActiveRecord::Base
  self.table_name = "admin_project_links"
  belongs_to :project, :class_name => 'Admin::Project'
  attr_accessible :href, :name, :project_id
  validates :href, :name, :presence => true
end
