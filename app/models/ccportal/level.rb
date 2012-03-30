class Ccportal::Level < Ccportal::Ccportal
  self.table_name = :portal_levels
  set_primary_key :level_id
  
  has_many :activities, :foreign_key => :activity_level, :class_name => 'Ccportal::Activity'
end
