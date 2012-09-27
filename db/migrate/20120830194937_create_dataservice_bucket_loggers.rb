class CreateDataserviceBucketLoggers < ActiveRecord::Migration
  def change
    create_table :dataservice_bucket_loggers do |t|
      t.integer :learner_id

      t.timestamps
    end

    add_index :dataservice_bucket_loggers, :learner_id
  end
end
