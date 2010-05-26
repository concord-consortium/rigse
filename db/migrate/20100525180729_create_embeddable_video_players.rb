class CreateEmbeddableVideoPlayers < ActiveRecord::Migration
  def self.up
    create_table :embeddable_video_players do |t|
      
      t.integer   "user_id"
      t.string    "uuid",        :limit => 36
      t.string    "name"
      t.string    "image_url"
      t.string    "video_url"
      t.text      "description"
      
      t.timestamps
    end
  end

  def self.down
    drop_table :embeddable_video_players
  end
end
