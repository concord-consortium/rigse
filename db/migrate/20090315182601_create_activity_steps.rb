class CreateInvestigationSteps < ActiveRecord::Migration
  def self.up
    create_table  :investigation_steps do |t|
      t.integer   :investigation_id
      t.integer   :step_number
      t.integer   :step_id
      t.string    :step_type
      t.string    :name
    end
    add_index('investigation_steps','step_id')
    add_index('investigation_steps','step_type')
    add_index('investigation_steps','step_number')
  end
  
  def self.down
    drop_table :investigation_steps
  end
end
