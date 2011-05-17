class AddInvestigationIdToExternalActivities < ActiveRecord::Migration
  def self.up
    add_column :external_activities, :investigation_id, :integer
  end

  def self.down
    remove_column :external_activities, :investigation_id
  end
end
