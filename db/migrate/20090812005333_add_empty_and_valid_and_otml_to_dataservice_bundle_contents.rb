class AddEmptyAndValidAndOtmlToDataserviceBundleContents < ActiveRecord::Migration
  def self.up
    add_column :dataservice_bundle_contents, :otml, :text, :limit => 16777215 # 16MB

    add_column :dataservice_bundle_contents, :processed, :boolean
    add_column :dataservice_bundle_contents, :valid_xml, :boolean
    add_column :dataservice_bundle_contents, :empty, :boolean
    add_column :dataservice_bundle_contents, :uuid, :string, :limit => 36

    add_index :dataservice_bundle_contents, :bundle_logger_id
  end

  def self.down
    remove_column :dataservice_bundle_contents, :otml
    
    remove_column :dataservice_bundle_contents, :processed
    remove_column :dataservice_bundle_contents, :valid_xml
    remove_column :dataservice_bundle_contents, :empty
    remove_column :dataservice_bundle_contents, :uuid
    
    remove_index :dataservice_bundle_contents, :bundle_logger_id
  end
end
