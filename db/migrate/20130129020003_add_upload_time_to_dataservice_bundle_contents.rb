class AddUploadTimeToDataserviceBundleContents < ActiveRecord::Migration
  def change
    add_column :dataservice_bundle_contents, :upload_time, :float
  end
end
