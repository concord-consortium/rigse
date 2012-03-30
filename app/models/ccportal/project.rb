class Ccportal::Project < Ccportal::Ccportal
  self.table_name = :portal_projects
  set_primary_key :project_id

  has_many :units, :foreign_key => :unit_project, :class_name => 'Ccportal::Unit'
  has_one :project_configuration, :class_name => 'Ccportal::ProjectConfiguration'

  # The method Ccportal::Project.getProjectIdFromPortalId isn't needed because the 
  # search can be performed more easily by using the dynamic finder capability
  # built into ActiveRecord.
  #
  # Ccportal::Project.find_by_project_sds_portal(21)
  # => #<Ccportal::Project project_id: 5, project_name: "RI-ITEST", ...

  def self.getProjectIdFromPortalId(portalId)
    Ccportal::Project.find(:first, :conditions => { :project_sds_portal => portalId })
  end
  
end
