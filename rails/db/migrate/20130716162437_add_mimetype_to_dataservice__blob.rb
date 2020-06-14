class AddMimetypeToDataserviceBlob < ActiveRecord::Migration
  def change
    add_column :dataservice_blobs, :mimetype, :string
    add_column :dataservice_blobs, :file_extension, :string
    add_column :dataservice_blobs, :learner_id, :integer
    add_column :dataservice_blobs, :checksum, :string
    add_index  :dataservice_blobs, :checksum
    add_index  :dataservice_blobs, :learner_id
  end
end
