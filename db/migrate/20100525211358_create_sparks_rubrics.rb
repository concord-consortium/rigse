class CreateSparksRubrics < ActiveRecord::Migration
  def self.up
    create_table :sparks_rubrics do |t|
      t.string 'rubric_id', :limit => 72
      t.string 'name', :limit => 48
      t.string 'description', :limit => 256
      t.text 'content'
      t.timestamps
    end
  end

  def self.down
    drop_table :sparks_rubrics
  end
end
