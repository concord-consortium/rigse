class ChangeImportDataType < ActiveRecord::Migration
  def up
  	change_column :imports, :import_data, :text, :limit => 4294967295
  end

  def down
  	change_column :imports, :import_data, :text
  end
end
