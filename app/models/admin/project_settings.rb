class Admin::ProjectSettings < ActiveRecord::Base
  belongs_to :admin_project

  serialize :states_and_provinces
  serialize :active_school_levels
end
