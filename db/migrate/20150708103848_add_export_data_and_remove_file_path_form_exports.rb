class AddExportDataAndRemoveFilePathFormExports < ActiveRecord::Migration
  def self.up
    remove_column :exports, :file_path
    add_column :exports, :export_data, :text, :limit => 4294967295
  end

  def self.down
    remove_column :exports, :export_data
    add_column :exports, :file_path, :string
  end
end
