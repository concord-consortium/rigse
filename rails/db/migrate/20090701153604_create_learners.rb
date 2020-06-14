class CreateLearners < ActiveRecord::Migration
  def self.up
    create_table :portal_learners do |t|

      t.string    :uuid, :limit => 36
      t.string    :name
      t.text      :description
      
      t.integer   :student_id
      t.integer   :offering_id

      t.timestamps
    end
  end

  def self.down
    drop_table :portal_learners
  end
end
