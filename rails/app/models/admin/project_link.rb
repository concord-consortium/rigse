class Admin::ProjectLink < ApplicationRecord
  self.table_name = "admin_project_links"
  belongs_to :project, :class_name => 'Admin::Project'
  validates :href, :name, :link_id, :presence => true

  self.extend SearchableModel

  class <<self
    def searchable_attributes
      %w{name href link_id}
    end
  end

end
