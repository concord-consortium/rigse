class CreateSubjects < ActiveRecord::Migration
  def self.up
    create_table :portal_subjects do |t|

      t.string    :uuid, :limit => 36
      t.string    :name
      t.text      :description
      
      t.integer   :teacher_id

      t.timestamps
    end
  end

  def self.down
    drop_table :portal_subjects
  end
end
