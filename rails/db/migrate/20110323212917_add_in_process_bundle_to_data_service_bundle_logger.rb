class AddInProcessBundleToDataServiceBundleLogger < ActiveRecord::Migration
  def self.up
    add_column :dataservice_bundle_loggers, :in_progress_bundle_id, :integer    
  end

  def self.down
    remove_column :dataservice_bundle_loggers, :in_progress_bundle_id
  end
end
