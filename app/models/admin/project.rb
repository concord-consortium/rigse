class Admin::Project < ActiveRecord::Base
  include Changeable

  self.table_name = 'admin_projects'

  has_many :project_materials
  has_many :activities, through: :project_materials, source: :material, source_type: 'Activity'
  has_many :investigations, through: :project_materials, source: :material, source_type: 'Investigation'
  has_many :external_activities, through: :project_materials, source: :material, source_type: 'ExternalActivity'
end
