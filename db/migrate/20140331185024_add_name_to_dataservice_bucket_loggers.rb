class AddNameToDataserviceBucketLoggers < ActiveRecord::Migration
  def change
    add_column :dataservice_bucket_loggers, :name, :string
    add_index :dataservice_bucket_loggers, :name
  end
end
