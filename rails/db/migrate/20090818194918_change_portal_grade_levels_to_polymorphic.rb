class ChangePortalGradeLevelsToPolymorphic < ActiveRecord::Migration
  def self.up
    add_column :portal_grade_levels, :has_grade_levels_id, :integer
    add_column :portal_grade_levels, :has_grade_levels_type, :string
    add_column :portal_grade_levels, :grade_id, :integer

    remove_column :portal_grade_levels, :order
    remove_column :portal_grade_levels, :school_id
  end

  def self.down
    add_column :portal_grade_levels, :order, :integer
    add_column :portal_grade_levels, :school_id, :integer

    remove_column :portal_grade_levels, :has_grade_levels_id
    remove_column :portal_grade_levels, :has_grade_levels_type
    remove_column :portal_grade_levels, :grade_id
  end
end
