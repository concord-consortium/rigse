class ChangeImportDataType < ActiveRecord::Migration[5.1]
  def up
  	change_column :imports, :import_data, :text, :limit => 4294967295
  end

  def down
  	change_column :imports, :import_data, :text
  end
end
