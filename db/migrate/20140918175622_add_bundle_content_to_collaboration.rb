class AddBundleContentToCollaboration < ActiveRecord::Migration
  def change
    add_column :dataservice_bundle_contents, :collaboration_id, :integer
  end
end
