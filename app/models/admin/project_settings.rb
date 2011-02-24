class Admin::ProjectSettings < ActiveRecord::Base
  belongs_to :admin_project, :class_name => "Admin::Project"

  serialize :states_and_provinces
  serialize :active_school_levels
end
