class AddUuidToDataserviceBlobs < ActiveRecord::Migration[5.1]
  def change
    add_column :dataservice_blobs, :uuid, :string, :limit => 36
  end
end
