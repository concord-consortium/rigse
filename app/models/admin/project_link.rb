class Admin::ProjectLink < ActiveRecord::Base
  self.table_name = "admin_project_links"
  belongs_to :project, :class_name => 'Admin::Project'
  attr_accessible :href, :name, :project_id, :link_id, :pop_out
  validates :href, :name, :link_id, :presence => true
end
