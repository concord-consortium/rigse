class AddAllowDraftsInAssignmentsFlagToSettings < ActiveRecord::Migration
  def self.up
    add_column :admin_project_settings, :allow_drafts_in_assignments, :boolean
  end

  def self.down
    remove_column :admin_project_settings, :allow_drafts_in_assignments
  end
end
