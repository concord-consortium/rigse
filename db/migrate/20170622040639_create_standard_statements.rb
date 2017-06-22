class CreateStandardStatements < ActiveRecord::Migration
  def change
    create_table :standard_statements do |t|
      t.string :description
      t.string :list_id
      t.string :uri

      t.timestamps
    end
  end
end
