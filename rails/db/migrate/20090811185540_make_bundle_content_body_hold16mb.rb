class MakeBundleContentBodyHold16mb < ActiveRecord::Migration[5.1]
  def self.up
    change_column :dataservice_bundle_contents, :body, :text, :limit => 16777215 # 16MB
  end

  def self.down
    change_column :dataservice_bundle_contents, :body, :text
  end
end
