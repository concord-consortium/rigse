class AddInstructionsToAdminProject < ActiveRecord::Migration
  def self.up
    add_column :admin_projects, :interactive_snapshot_instructions, :text
    add_column :admin_projects, :digital_microscope_snapshot_instructions, :text
  end

  def self.down
    remove_column :admin_projects, :digital_microscope_snapshot_instructions
    remove_column :admin_projects, :interactive_snapshot_instructions
  end
end
