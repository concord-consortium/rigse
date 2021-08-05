class AddImportDataToImports < ActiveRecord::Migration[5.1]
  def up
    add_column :imports, :import_data, :text
  end

  def down
    remove_column :imports, :import_data
  end
end
