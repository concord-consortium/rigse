class CreateDataserviceBlobs < ActiveRecord::Migration
  def self.up
    create_table :dataservice_blobs do |t|
      t.binary :content, :limit => 16777215
      t.string :token
      t.integer :bundle_content_id
      
      t.timestamps
    end

    add_index :dataservice_blobs, :bundle_content_id
  end

  def self.down
    remove_index :dataservice_blobs, :bundle_content_id
    
    drop_table :dataservice_blobs
  end
end
