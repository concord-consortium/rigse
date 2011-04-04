class DefaultsForBundleContents < ActiveRecord::Migration
  def self.up
    # 1. set default values on the tables
    change_column_default(:dataservice_bundle_contents, :empty, true)
    change_column_default(:dataservice_bundle_contents, :valid_xml, false)

    # 2. find null values and convert to 'false' or 0
    execute "UPDATE dataservice_bundle_contents set empty = 0 where empty is null"
    execute "UPDATE dataservice_bundle_contents set valid_xml = 0 where valid_xml is null"
  end

  def self.down
    # 1. remove the default values on the table
    change_column_default(:dataservice_bundle_contents, :empty, nil)
    change_column_default(:dataservice_bundle_contents, :valid_xml, nil)

    # 2. find zero values and update to null
    execute "UPDATE dataservice_bundle_contents set empty = null where empty = 0"
    execute "UPDATE dataservice_bundle_contents set valid_xml = null where valid_xml = 0"
  end
end
