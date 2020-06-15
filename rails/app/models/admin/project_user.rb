class Admin::ProjectUser < ActiveRecord::Base
  self.table_name = "admin_project_users"
  belongs_to :project, :class_name => 'Admin::Project'
  belongs_to :user, :class_name => 'User'
  validates :project_id, :user_id, :presence => true
end
