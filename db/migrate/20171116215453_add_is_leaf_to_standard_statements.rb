class AddIsLeafToStandardStatements < ActiveRecord::Migration
  def change
    add_column :standard_statements, :is_leaf, :boolean
  end
end
