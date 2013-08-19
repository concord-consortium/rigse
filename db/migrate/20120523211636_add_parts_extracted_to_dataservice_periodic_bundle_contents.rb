class AddPartsExtractedToDataservicePeriodicBundleContents < ActiveRecord::Migration
  def self.up
    add_column :dataservice_periodic_bundle_contents, :parts_extracted, :boolean

    # set all the existing contents as having been extracted.
    execute "UPDATE dataservice_periodic_bundle_contents SET parts_extracted = 1 WHERE id > 0"
  end

  def self.down
    remove_column :dataservice_periodic_bundle_contents, :parts_extracted
  end
end
