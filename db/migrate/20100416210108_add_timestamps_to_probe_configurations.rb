class AddTimestampsToProbeConfigurations < ActiveRecord::Migration
  
  @@tables = %w{probe_calibrations probe_data_filters probe_physical_units probe_probe_types probe_vendor_interfaces}

  def self.up
    @@tables.each do |table|
      add_column table, :created_at, :datetime
      add_column table, :updated_at, :datetime
    end
  end

  def self.down
    @@tables.each do |table|
      remove_column table, :created_at
      remove_column table, :updated_at
    end
  end

end
