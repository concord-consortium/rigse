class CreateGradeLevels < ActiveRecord::Migration
  def self.up
    create_table :portal_grade_levels do |t|

      t.string    :uuid, :limit => 36
      t.string    :name
      t.text      :description
      
      t.integer   :order
      t.integer   :school_id

      t.timestamps
    end
    
    create_table :portal_grade_levels_teachers, :id => false do |t|
      t.integer   :grade_level_id
      t.integer   :teacher_id
      
      t.timestamps
    end
  end

  def self.down
    drop_table :portal_grade_levels_teachers
    drop_table :portal_grade_levels
  end
end
