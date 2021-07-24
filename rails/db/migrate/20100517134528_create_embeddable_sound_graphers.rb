class CreateEmbeddableSoundGraphers < ActiveRecord::Migration[5.1]
  def self.up
    create_table :embeddable_sound_graphers do |t|
      t.integer   "user_id"
      t.string    "uuid",        :limit => 36
      t.string    "name"
      
      t.timestamps
    end
  end

  def self.down
    drop_table :embeddable_sound_graphers
  end
end
