class CreateDataservicePeriodicBundleLoggers < ActiveRecord::Migration
  def self.up
    create_table :dataservice_periodic_bundle_loggers do |t|
      t.integer :learner_id
      t.text    :imports

      t.timestamps
    end

    add_index :dataservice_periodic_bundle_loggers, :learner_id, :name => 'learner_index'
  end

  def self.down
    remove_index :dataservice_periodic_bundle_loggers, :name => 'learner_index'
    drop_table :dataservice_periodic_bundle_loggers
  end
end
