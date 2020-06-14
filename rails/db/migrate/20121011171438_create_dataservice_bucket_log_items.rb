class CreateDataserviceBucketLogItems < ActiveRecord::Migration
  def change
    create_table :dataservice_bucket_log_items do |t|
      t.text :content
      t.integer :bucket_logger_id

      t.timestamps
    end

    add_index :dataservice_bucket_log_items, :bucket_logger_id
  end
end
