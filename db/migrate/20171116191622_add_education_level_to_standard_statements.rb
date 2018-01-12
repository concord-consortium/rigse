class AddEducationLevelToStandardStatements < ActiveRecord::Migration
  def change
    add_column :standard_statements, :education_level, :string
  end
end
