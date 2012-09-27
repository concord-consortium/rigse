class CreateDataserviceBucketContents < ActiveRecord::Migration
  def change
    create_table :dataservice_bucket_contents do |t|
      t.integer :bucket_logger_id
      t.text :body
      t.boolean :processed
      t.boolean :empty

      t.timestamps
    end

    add_index :dataservice_bucket_contents, :bucket_logger_id
  end
end
