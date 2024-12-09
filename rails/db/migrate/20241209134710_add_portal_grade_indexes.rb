class AddPortalGradeIndexes < ActiveRecord::Migration[6.1]
  def change
    add_index :portal_grade_levels, [:has_grade_levels_id, :has_grade_levels_type],
      :name => 'by_grade_levels_id_and_type'
    add_index :portal_grade_levels, [:grade_id],
      :name => 'by_grade_id'
  end
end
