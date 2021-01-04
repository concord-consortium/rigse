class AddCalibrationAndStaticToDataCollectors < ActiveRecord::Migration
  def self.up
    add_column :data_collectors, :calibration_id, :integer
    add_column :data_collectors, :static, :boolean
  end

  def self.down
    remove_column :data_collectors, :static
    remove_column :data_collectors, :calibration_id
  end
end
