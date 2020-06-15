class AddUuidToDataserviceBlobs < ActiveRecord::Migration
  def change
    add_column :dataservice_blobs, :uuid, :string, :limit => 36
  end
end
