class Admin::ProjectMaterial < ActiveRecord::Base
  include Changeable

  attr_accessible :project_id, :material_id, :material_type

  self.table_name = 'admin_project_materials'

  belongs_to :project
  belongs_to :material, polymorphic: true
end
