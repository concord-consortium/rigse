class AddBundleContentToCollaboration < ActiveRecord::Migration[5.1]
  def change
    add_column :dataservice_bundle_contents, :collaboration_id, :integer
  end
end
