class AddPeriodicBundleContentIdToDataserviceBlobs < ActiveRecord::Migration
  def self.up
    add_column :dataservice_blobs, :periodic_bundle_content_id, :integer
    add_index  :dataservice_blobs, :periodic_bundle_content_id, :name => 'pbc_idx'
  end

  def self.down
    remove_index  :dataservice_blobs, :name => 'pbc_idx'
    remove_column :dataservice_blobs, :periodic_bundle_content_id
  end
end
