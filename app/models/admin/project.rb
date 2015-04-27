class Admin::Project < ActiveRecord::Base
  include Changeable

  self.table_name = 'admin_projects'

  self.extend SearchableModel
  @@searchable_attributes = %w{name}

  def self.searchable_attributes
    @@searchable_attributes
  end

  has_many :project_materials
  has_many :activities, through: :project_materials, source: :material, source_type: 'Activity'
  has_many :investigations, through: :project_materials, source: :material, source_type: 'Investigation'
  has_many :external_activities, through: :project_materials, source: :material, source_type: 'ExternalActivity'
end
