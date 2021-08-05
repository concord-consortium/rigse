class CreateDataserviceBundleLoggers < ActiveRecord::Migration[5.1]
  def self.up
    create_table :dataservice_bundle_loggers do |t|
            
      t.timestamps
    end
  end

  def self.down
    drop_table :dataservice_bundle_loggers
  end
end
