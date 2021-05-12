class AddOriginalBodyToBundleContents < ActiveRecord::Migration[5.1]
  def self.up
    add_column :dataservice_bundle_contents, :original_body, :text
  end

  def self.down
    remove_column :dataservice_bundle_contents, :original_body
  end
end
