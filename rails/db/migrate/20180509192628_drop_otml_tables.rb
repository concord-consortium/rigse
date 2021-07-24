class DropOtmlTables < ActiveRecord::Migration[5.1]
  def remove_table(name)
    drop_table name.to_sym if ApplicationRecord.connection.tables.include?(name)
  end

  def up
    [
      "otml_categories_otrunk_imports",
      "otml_files_otrunk_imports",
      "otml_files_otrunk_view_entries",
      "otrunk_example_otml_categories",
      "otrunk_example_otml_files"
    ].each { |table| self.remove_table(table) }
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
