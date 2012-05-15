class Ccportal::Unit < Ccportal::Ccportal
  self.table_name = :portal_units
  self.primary_key = :unit_id

  belongs_to :project, :foreign_key => :unit_project, :class_name => 'Ccportal::Project'

  has_many :activities, :foreign_key => :activity_unit, :class_name => 'Ccportal::Activity'
end