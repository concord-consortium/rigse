class AddOriginalBodyToBundleContents < ActiveRecord::Migration
  def self.up
    add_column :dataservice_bundle_contents, :original_body, :text
  end

  def self.down
    remove_column :dataservice_bundle_contents, :original_body
  end
end
