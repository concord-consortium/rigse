class CreateDataservicePeriodicBundleContents < ActiveRecord::Migration
  def self.up
    create_table :dataservice_periodic_bundle_contents do |t|
      t.integer :periodic_bundle_logger_id
      t.text :body, :limit => (16.megabytes-2)
      t.boolean :processed
      t.boolean :valid_xml
      t.boolean :empty
      t.string :uuid

      t.timestamps
    end

    add_index :dataservice_periodic_bundle_contents, :periodic_bundle_logger_id, :name => 'bundle_logger_index'
  end

  def self.down
    remove_index :dataservice_periodic_bundle_contents, :name => 'bundle_logger_index'
    drop_table :dataservice_periodic_bundle_contents
  end
end
