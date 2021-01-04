class CreateDataservicePeriodicBundleParts < ActiveRecord::Migration
  def self.up
    create_table :dataservice_periodic_bundle_parts do |t|
      t.integer :periodic_bundle_logger_id
      t.boolean :delta, :default => true
      t.string  :key
      t.text    :value, :limit => 4.megabytes

      t.timestamps
    end

    add_index :dataservice_periodic_bundle_parts, :periodic_bundle_logger_id, :name => 'bundle_logger_index'
    add_index :dataservice_periodic_bundle_parts, :key, :name => 'parts_key_index'
  end

  def self.down
    remove_index :dataservice_periodic_bundle_parts, :name => 'bundle_logger_index'
    remove_index :dataservice_periodic_bundle_parts, :name => 'parts_key_index'
    drop_table :dataservice_periodic_bundle_parts
  end
end
