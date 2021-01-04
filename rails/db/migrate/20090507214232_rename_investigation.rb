class RenameInvestigation < ActiveRecord::Migration
  def self.up
    rename_table :investigations, :activities
    rename_column :sections, :investigation_id, :activity_id
  end 

  def self.down
    rename_column :sections, :activity_id, :investigation_id
    rename_table :activities, :investigations
  end

end
