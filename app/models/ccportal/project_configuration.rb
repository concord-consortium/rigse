class Ccportal::ProjectConfiguration < Ccportal::Ccportal
  set_table_name :portal_project_configurations
  set_primary_key :project_configuration_id

  belongs_to :project, :class_name => 'Ccportal::Project'
  
end
