class AddUserIdToProbeCalibrations < ActiveRecord::Migration
  def self.up
    add_column :probe_calibrations, :user_id, :integer
  end

  def self.down
    remove_column :probe_calibrations, :user_id
  end
end
