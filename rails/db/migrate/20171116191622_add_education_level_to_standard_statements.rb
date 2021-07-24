class AddEducationLevelToStandardStatements < ActiveRecord::Migration[5.1]
  def change
    add_column :standard_statements, :education_level, :string
  end
end
