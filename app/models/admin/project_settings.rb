class Admin::ProjectSettings < ActiveRecord::Base
  belongs_to :admin_project, :class_name => "Admin::Project"
  belongs_to :default_admin_user, :class_name => "User", :foreign_key => "default_admin_user_id"

  has_and_belongs_to_many :maven_jnlp_maven_jnlp_servers
  has_and_belongs_to_many :maven_jnlp_maven_jnlp_families
  has_and_belongs_to_many :portal_grade_levels

  serialize :states_and_provinces
  serialize :active_school_levels
end
