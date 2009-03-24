class CreateActivitySteps < ActiveRecord::Migration
  def self.up
    create_table  :activity_steps do |t|
      t.integer   :activity_id
      t.integer   :step_number
      t.integer   :step_id
      t.string    :step_type
      t.string    :name
    end
    add_index('activity_steps','step_id')
    add_index('activity_steps','step_type')
    add_index('activity_steps','step_number')
  end
  
  def self.down
    drop_table :activity_steps
  end
end
