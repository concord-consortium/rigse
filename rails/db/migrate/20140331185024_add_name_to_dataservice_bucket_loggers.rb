class AddNameToDataserviceBucketLoggers < ActiveRecord::Migration[5.1]
  def change
    add_column :dataservice_bucket_loggers, :name, :string
    add_index :dataservice_bucket_loggers, :name
  end
end
