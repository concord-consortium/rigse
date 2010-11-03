class AddEmbeddableDiySensor < ActiveRecord::Migration
  def self.up
    create_table :embeddable_diy_sensors, :force => true do |t|
      t.integer     :user_id
      t.string      :uuid,               :limit => 36
     
      # proxy associations: 
      t.integer :prototype_id
      
      # serialized customizations:
      t.text :customizations
      t.timestamps 
    end
    add_index :embeddable_diy_sensors, :prototype_id
  end

  def self.down
    remove_index :embeddable_diy_sensors, :prototype_id
    drop_table :embeddable_diy_sensors 
  end
end
