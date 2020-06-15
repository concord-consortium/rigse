class CreateStandardStatements < ActiveRecord::Migration
  def change
    create_table :standard_statements do |t|
      t.string  :uri
      t.string  :doc
      t.string  :statement_notation
      t.string  :statement_label
      t.text    :description
      t.text    :parents
      t.string  :material_type
      t.integer :material_id

      t.timestamps
    end

    add_index "standard_statements", ["uri", "material_type", "material_id"], :name => "standard_unique", :unique => true

  end

end
