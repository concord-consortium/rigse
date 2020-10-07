class Admin::ProjectLink < ActiveRecord::Base

  attr_accessible :project_id, :name, :href, :link_id, :pop_out, :position

  self.table_name = "admin_project_links"
  belongs_to :project, :class_name => 'Admin::Project'
  attr_accessible :href, :name, :project_id, :link_id, :pop_out, :position
  validates :href, :name, :link_id, :presence => true

  self.extend SearchableModel

  class <<self
    def searchable_attributes
      %w{name href link_id}
    end
  end

end
