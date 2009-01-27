class CreateActivities < ActiveRecord::Migration
  def self.up
    create_table :activities do |t|
      t.string :title
      t.text :context
      t.text :opportunities
      t.text :objectives
      t.text :procedures_opening
      t.text :procedures_engagement
      t.text :procedures_closure
      t.text :assessment
      t.text :reflection

      t.timestamps
    end
  end

  def self.down
    drop_table :activities
  end
end
