class RemoveProbeFields < ActiveRecord::Migration
  def remove_table(name)
    drop_table name.to_sym if ActiveRecord::Base.connection.tables.include?(name)
  end

  def up
    [
      "admin_settings_vendor_interfaces",
      "probe_calibrations",
      "probe_data_filters",
      "probe_device_configs",
      "probe_physical_units",
      "probe_probe_types",
      "probe_vendor_interfaces"
    ].each{|t| remove_table(t)}

    remove_index :users, :vendor_interface_id
    remove_column :users, :vendor_interface_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
