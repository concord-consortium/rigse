class Admin::ProjectUser < ActiveRecord::Base

  attr_accessible :project_id, :user_id, :is_admin, :is_researcher

  scope :is_admin, -> { where is_admin: true }
  scope :is_researcher, -> { where is_researcher: true }
  self.table_name = "admin_project_users"
  belongs_to :project, :class_name => 'Admin::Project'
  belongs_to :user, :class_name => 'User'
  validates :project_id, :user_id, :presence => true
end
