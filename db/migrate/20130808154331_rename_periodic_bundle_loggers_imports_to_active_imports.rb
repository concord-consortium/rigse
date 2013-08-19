class RenamePeriodicBundleLoggersImportsToActiveImports < ActiveRecord::Migration
  def self.up
    rename_column :dataservice_periodic_bundle_loggers, :imports, :active_imports
  end

  def self.down
    rename_column :dataservice_periodic_bundle_loggers, :active_imports, :imports
  end
end
