class AddDefaultPartsExtractedToDataservicePeriodicBundleContent < ActiveRecord::Migration
  def up
    change_column :dataservice_periodic_bundle_contents, :parts_extracted, :boolean, :default => false
    execute "UPDATE dataservice_periodic_bundle_contents SET parts_extracted=0 WHERE parts_extracted IS NULL"
  end

  def down
    change_column :dataservice_periodic_bundle_contents, :parts_extracted, :boolean
  end
end
