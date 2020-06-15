class RemoveTimesStampsFromHasAndBelongsToManyTables < ActiveRecord::Migration
  def self.up
    remove_column :embeddable_biologica_chromosome_zooms_organisms, :created_at
    remove_column :embeddable_biologica_chromosome_zooms_organisms, :updated_at
    remove_column :embeddable_biologica_multiple_organisms_organisms, :created_at
    remove_column :embeddable_biologica_multiple_organisms_organisms, :updated_at
    remove_column :embeddable_biologica_organisms_pedigrees, :created_at
    remove_column :embeddable_biologica_organisms_pedigrees, :updated_at
    remove_column :portal_courses_grade_levels, :created_at
    remove_column :portal_courses_grade_levels, :updated_at
    remove_column :portal_grade_levels_teachers, :created_at
    remove_column :portal_grade_levels_teachers, :updated_at
  end

  def self.down
    add_column :embeddable_biologica_chromosome_zooms_organisms, :created_at, :datetime
    add_column :embeddable_biologica_chromosome_zooms_organisms, :updated_at, :datetime
    add_column :embeddable_biologica_multiple_organisms_organisms, :created_at, :datetime
    add_column :embeddable_biologica_multiple_organisms_organisms, :updated_at, :datetime
    add_column :embeddable_biologica_organisms_pedigrees, :created_at, :datetime
    add_column :embeddable_biologica_organisms_pedigrees, :updated_at, :datetime
    add_column :portal_courses_grade_levels, :created_at, :datetime
    add_column :portal_courses_grade_levels, :updated_at, :datetime
    add_column :portal_grade_levels_teachers, :created_at, :datetime
    add_column :portal_grade_levels_teachers, :updated_at, :datetime
  end
end
