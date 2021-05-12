class AddUploadTimeToDataserviceBundleContents < ActiveRecord::Migration[5.1]
  def change
    add_column :dataservice_bundle_contents, :upload_time, :float
  end
end
